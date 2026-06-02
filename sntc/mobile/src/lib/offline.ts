// =============================================================================
// SNTC — File d'attente hors-ligne (outbox)
// =============================================================================
// Les saisies (ventes, relevés de stock) sont écrites localement puis
// rejouées vers Supabase dès que le réseau revient. Chaque opération porte un
// client_uuid : la contrainte d'unicité côté base garantit l'idempotence
// (pas de doublon même si la synchro est rejouée plusieurs fois).
// -----------------------------------------------------------------------------

import AsyncStorage from "@react-native-async-storage/async-storage";
import * as Network from "expo-network";
import { supabase } from "./supabase";

const OUTBOX_KEY = "sntc.outbox.v1";

export type OutboxOp =
  | { kind: "vente"; client_uuid: string; payload: Record<string, unknown> }
  | { kind: "stock"; client_uuid: string; payload: Record<string, unknown> };

async function readOutbox(): Promise<OutboxOp[]> {
  const raw = await AsyncStorage.getItem(OUTBOX_KEY);
  return raw ? JSON.parse(raw) : [];
}

async function writeOutbox(ops: OutboxOp[]): Promise<void> {
  await AsyncStorage.setItem(OUTBOX_KEY, JSON.stringify(ops));
}

/** Ajoute une opération à la file (toujours, qu'on soit en ligne ou non). */
export async function enqueue(op: OutboxOp): Promise<void> {
  const ops = await readOutbox();
  ops.push(op);
  await writeOutbox(ops);
}

/** Nombre d'opérations en attente de synchronisation. */
export async function pendingCount(): Promise<number> {
  return (await readOutbox()).length;
}

export async function isOnline(): Promise<boolean> {
  try {
    const s = await Network.getNetworkStateAsync();
    return Boolean(s.isConnected && s.isInternetReachable);
  } catch {
    return false;
  }
}

/**
 * Tente de vider la file vers Supabase. Sûr à appeler souvent : ne fait rien
 * hors-ligne et les doublons sont absorbés par la base (upsert idempotent).
 * Renvoie le nombre d'opérations synchronisées.
 */
export async function flush(): Promise<number> {
  if (!(await isOnline())) return 0;

  const ops = await readOutbox();
  if (ops.length === 0) return 0;

  const restantes: OutboxOp[] = [];
  let synced = 0;

  for (const op of ops) {
    try {
      const table = op.kind === "vente" ? "ventes" : "stocks";
      const { error } =
        op.kind === "vente"
          ? await supabase.from(table).upsert(op.payload, { onConflict: "station_id,client_uuid" })
          : await supabase.from(table).upsert(op.payload, { onConflict: "station_id,produit" });

      if (error) {
        // 23505 = doublon déjà synchronisé -> on considère l'op réussie
        if (error.code === "23505") synced++;
        else restantes.push(op); // erreur réseau/transitoire : on réessaiera
      } else {
        synced++;
      }
    } catch {
      restantes.push(op);
    }
  }

  await writeOutbox(restantes);
  return synced;
}

/** Démarre une synchro périodique en arrière-plan (toutes les 30 s). */
export function startAutoSync(onSync?: (n: number) => void): () => void {
  const id = setInterval(async () => {
    const n = await flush();
    if (n > 0) onSync?.(n);
  }, 30_000);
  return () => clearInterval(id);
}
