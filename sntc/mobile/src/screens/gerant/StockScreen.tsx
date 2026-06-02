// Relevé du stock physique (gérant). Le stock théorique et les écarts sont
// recalculés automatiquement côté base après synchronisation.
import React, { useEffect, useState } from "react";
import { View, Text, TextInput, StyleSheet, Alert } from "react-native";
import { supabase } from "@/lib/supabase";
import { useAuth } from "@/contexts/AuthContext";
import { BigButton, Card } from "@/components/ui";
import { colors, spacing, radius, fontSize } from "@/theme";

export default function StockScreen({ navigation }: any) {
  const { profile } = useAuth();
  const [essence, setEssence] = useState("");
  const [gasoil, setGasoil] = useState("");
  const [theorique, setTheorique] = useState<{ essence?: number; gasoil?: number }>({});
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    (async () => {
      const { data } = await supabase.from("stocks").select("*").eq("station_id", profile!.station_id);
      const e = data?.find((d) => d.produit === "essence");
      const g = data?.find((d) => d.produit === "gasoil");
      setEssence(String(e?.stock_physique ?? ""));
      setGasoil(String(g?.stock_physique ?? ""));
      setTheorique({ essence: e?.stock_theorique, gasoil: g?.stock_theorique });
    })();
  }, []);

  async function enregistrer() {
    setSaving(true);
    const rows = [
      { station_id: profile!.station_id, produit: "essence", stock_physique: parseFloat(essence) || 0 },
      { station_id: profile!.station_id, produit: "gasoil", stock_physique: parseFloat(gasoil) || 0 },
    ];
    const { error } = await supabase.from("stocks").upsert(rows, { onConflict: "station_id,produit" });
    setSaving(false);
    if (error) return Alert.alert("Erreur", error.message);
    Alert.alert("Stock enregistré", "Les écarts sont recalculés automatiquement.", [
      { text: "OK", onPress: () => navigation.goBack() },
    ]);
  }

  return (
    <View style={s.container}>
      <Card>
        <Text style={s.label}>Stock ESSENCE relevé (litres)</Text>
        <TextInput style={s.input} keyboardType="decimal-pad" value={essence} onChangeText={setEssence} />
        {theorique.essence != null && <Text style={s.hint}>Théorique attendu : {Math.round(theorique.essence)} L</Text>}
      </Card>
      <Card>
        <Text style={s.label}>Stock GASOIL relevé (litres)</Text>
        <TextInput style={s.input} keyboardType="decimal-pad" value={gasoil} onChangeText={setGasoil} />
        {theorique.gasoil != null && <Text style={s.hint}>Théorique attendu : {Math.round(theorique.gasoil)} L</Text>}
      </Card>
      <BigButton label="VALIDER LE RELEVÉ" onPress={enregistrer} loading={saving} color={colors.gold} />
    </View>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.bg, padding: spacing.md },
  label: { fontSize: fontSize.base, fontWeight: "700", color: colors.text },
  input: {
    backgroundColor: "#fff", borderWidth: 2, borderColor: colors.navy, borderRadius: radius.md,
    fontSize: fontSize.xl, fontWeight: "800", textAlign: "center", padding: spacing.md, marginTop: spacing.sm,
  },
  hint: { color: colors.muted, marginTop: spacing.xs },
});
