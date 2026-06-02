// Accueil gérant : état de la station, stocks, alertes, accès saisie rapide.
import React, { useCallback, useEffect, useState } from "react";
import { View, Text, ScrollView, StyleSheet, RefreshControl } from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import { supabase } from "@/lib/supabase";
import { useAuth } from "@/contexts/AuthContext";
import { pendingCount, flush } from "@/lib/offline";
import { BigButton, Card, EtatBadge, Stat } from "@/components/ui";
import { colors, spacing, fontSize } from "@/theme";

export default function GerantHome({ navigation }: any) {
  const { profile, signOut } = useAuth();
  const [station, setStation] = useState<any>(null);
  const [stocks, setStocks] = useState<any[]>([]);
  const [alertes, setAlertes] = useState<any[]>([]);
  const [pending, setPending] = useState(0);
  const [refreshing, setRefreshing] = useState(false);

  const charger = useCallback(async () => {
    if (!profile?.station_id) return;
    await flush();
    const [{ data: st }, { data: sk }, { data: al }, p] = await Promise.all([
      supabase.from("stations").select("*").eq("id", profile.station_id).single(),
      supabase.from("stocks").select("*").eq("station_id", profile.station_id),
      supabase.from("alertes").select("*").eq("station_id", profile.station_id).eq("resolue", false),
      pendingCount(),
    ]);
    setStation(st); setStocks(sk ?? []); setAlertes(al ?? []); setPending(p);
  }, [profile]);

  useFocusEffect(useCallback(() => { charger(); }, [charger]));

  const essence = stocks.find((s) => s.produit === "essence");
  const gasoil = stocks.find((s) => s.produit === "gasoil");

  return (
    <ScrollView
      style={s.container}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await charger(); setRefreshing(false); }} />}
    >
      {pending > 0 && (
        <View style={s.offline}><Text style={s.offlineText}>{pending} saisie(s) en attente de synchronisation</Text></View>
      )}

      <Card>
        <View style={s.row}>
          <Text style={s.title}>{station?.nom ?? "Ma station"}</Text>
          {station && <EtatBadge etat={station.etat} />}
        </View>
        <Text style={s.muted}>{station?.code}</Text>
        <View style={s.stats}>
          <Stat label="Essence (L)" value={fmt(essence?.stock_physique)} color={colors.navy} />
          <Stat label="Gasoil (L)" value={fmt(gasoil?.stock_physique)} color={colors.navy} />
        </View>
      </Card>

      <BigButton label="+ SAISIR UNE VENTE" onPress={() => navigation.navigate("VenteRapide")} color={colors.gold} />
      <BigButton label="RELEVER LE STOCK" onPress={() => navigation.navigate("Stock")} />

      {alertes.length > 0 && (
        <Card style={{ borderColor: colors.danger }}>
          <Text style={[s.title, { color: colors.danger }]}>Alertes ({alertes.length})</Text>
          {alertes.map((a) => (
            <Text key={a.id} style={s.alerte}>• {a.message}</Text>
          ))}
        </Card>
      )}

      <BigButton label="Se déconnecter" onPress={signOut} color={colors.muted} />
    </ScrollView>
  );
}

const fmt = (n?: number) => (n != null ? Math.round(n).toLocaleString("fr-FR") : "—");

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.bg, padding: spacing.md },
  row: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  title: { fontSize: fontSize.lg, fontWeight: "800", color: colors.text },
  muted: { color: colors.muted, marginTop: 2 },
  stats: { flexDirection: "row", marginTop: spacing.md },
  alerte: { color: colors.text, marginTop: spacing.xs, fontSize: fontSize.base },
  offline: { backgroundColor: colors.jaune, padding: spacing.sm, borderRadius: 8, marginBottom: spacing.sm },
  offlineText: { color: "#000", fontWeight: "700", textAlign: "center" },
});
