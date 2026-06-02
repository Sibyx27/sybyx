// Saisie rapide d'une vente — fonctionne hors-ligne (file d'attente outbox).
import React, { useState } from "react";
import { View, Text, TextInput, StyleSheet, Alert } from "react-native";
import { randomUUID } from "expo-crypto";
import { useAuth } from "@/contexts/AuthContext";
import { enqueue, flush, isOnline } from "@/lib/offline";
import { BigButton } from "@/components/ui";
import { colors, spacing, radius, fontSize } from "@/theme";

export default function VenteRapideScreen({ navigation }: any) {
  const { profile } = useAuth();
  const [produit, setProduit] = useState<"essence" | "gasoil">("gasoil");
  const [volume, setVolume] = useState("");
  const [saving, setSaving] = useState(false);

  async function enregistrer() {
    const v = parseFloat(volume.replace(",", "."));
    if (!v || v <= 0) return Alert.alert("Volume invalide", "Entrez un volume en litres.");
    setSaving(true);

    // UUID client : garantit l'idempotence à la synchro
    const client_uuid =
      (globalThis as any).crypto?.randomUUID?.() ?? randomUUID();

    await enqueue({
      kind: "vente",
      client_uuid,
      payload: {
        station_id: profile!.station_id,
        produit,
        volume: v,
        client_uuid,
        saisie_par: profile!.id,
        vendue_le: new Date().toISOString(),
      },
    });

    const online = await isOnline();
    if (online) await flush();
    setSaving(false);

    Alert.alert(
      "Vente enregistrée",
      online ? "Synchronisée." : "Sauvegardée hors-ligne, synchro automatique au retour du réseau.",
      [{ text: "OK", onPress: () => navigation.goBack() }],
    );
  }

  return (
    <View style={s.container}>
      <Text style={s.label}>Produit</Text>
      <View style={s.toggle}>
        {(["gasoil", "essence"] as const).map((p) => (
          <Text
            key={p}
            onPress={() => setProduit(p)}
            style={[s.toggleItem, produit === p && s.toggleActive]}
          >
            {p.toUpperCase()}
          </Text>
        ))}
      </View>

      <Text style={s.label}>Volume vendu (litres)</Text>
      <TextInput
        style={s.bigInput}
        keyboardType="decimal-pad"
        placeholder="0"
        value={volume}
        onChangeText={setVolume}
        autoFocus
      />

      <BigButton label="ENREGISTRER" onPress={enregistrer} loading={saving} color={colors.gold} />
    </View>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.bg, padding: spacing.lg },
  label: { fontSize: fontSize.base, fontWeight: "700", marginTop: spacing.md, color: colors.text },
  toggle: { flexDirection: "row", marginTop: spacing.sm, gap: spacing.sm },
  toggleItem: {
    flex: 1, textAlign: "center", paddingVertical: spacing.md, borderRadius: radius.md,
    backgroundColor: "#fff", borderWidth: 1, borderColor: colors.border, fontWeight: "700", fontSize: fontSize.base,
    overflow: "hidden",
  },
  toggleActive: { backgroundColor: colors.navy, color: "#fff", borderColor: colors.navy },
  bigInput: {
    backgroundColor: "#fff", borderWidth: 2, borderColor: colors.navy, borderRadius: radius.md,
    fontSize: fontSize.xxl, fontWeight: "800", textAlign: "center", padding: spacing.lg, marginTop: spacing.sm,
  },
});
