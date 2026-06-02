// Tableau de bord national (mobile) : KPIs nationaux + alertes critiques.
// La carte interactive Mapbox complète est sur le tableau de bord Web.
import React, { useCallback, useState } from "react";
import { View, Text, ScrollView, StyleSheet, RefreshControl } from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import { supabase } from "@/lib/supabase";
import { useAuth } from "@/contexts/AuthContext";
import { BigButton, Card, Stat } from "@/components/ui";
import { colors, spacing, fontSize } from "@/theme";

export default function AdminHome() {
  const { signOut } = useAuth();
  const [kpi, setKpi] = useState<any>(null);
  const [regions, setRegions] = useState<any[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const charger = useCallback(async () => {
    const [{ data: k }, { data: r }] = await Promise.all([
      supabase.from("v_dashboard_national").select("*").single(),
      supabase.from("v_stock_par_region").select("*"),
    ]);
    setKpi(k); setRegions(r ?? []);
  }, []);

  useFocusEffect(useCallback(() => { charger(); }, [charger]));

  return (
    <ScrollView
      style={s.container}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await charger(); setRefreshing(false); }} />}
    >
      <Card>
        <Text style={s.h}>Stock national</Text>
        <View style={s.row}>
          <Stat label="Essence (L)" value={fmt(kpi?.stock_national_essence)} />
          <Stat label="Gasoil (L)" value={fmt(kpi?.stock_national_gasoil)} />
        </View>
      </Card>

      <Card>
        <View style={s.row}>
          <Stat label="Stations" value={fmt(kpi?.nb_stations)} />
          <Stat label="Livraisons jour" value={fmt(kpi?.livraisons_jour)} />
        </View>
        <View style={s.row}>
          <Stat label="En rupture" value={fmt(kpi?.stations_rupture)} color={colors.rouge} />
          <Stat label="Suspectes" value={fmt(kpi?.stations_suspectes)} color={colors.jaune} />
          <Stat label="Alertes critiques" value={fmt(kpi?.alertes_critiques)} color={colors.danger} />
        </View>
      </Card>

      <Card>
        <Text style={s.h}>Stock par région</Text>
        {regions.map((r) => (
          <View key={r.region_id} style={s.regionRow}>
            <Text style={s.region}>{r.region}</Text>
            <Text style={s.regionVal}>{fmt(r.stock_essence + r.stock_gasoil)} L</Text>
          </View>
        ))}
      </Card>

      <BigButton label="Se déconnecter" onPress={signOut} color={colors.muted} />
    </ScrollView>
  );
}

const fmt = (n?: number) => (n != null ? Math.round(n).toLocaleString("fr-FR") : "—");

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.bg, padding: spacing.md },
  h: { fontSize: fontSize.lg, fontWeight: "800", marginBottom: spacing.sm },
  row: { flexDirection: "row" },
  regionRow: { flexDirection: "row", justifyContent: "space-between", paddingVertical: spacing.sm, borderTopWidth: 1, borderTopColor: colors.border },
  region: { fontSize: fontSize.base, color: colors.text },
  regionVal: { fontSize: fontSize.base, fontWeight: "700", color: colors.navy },
});
