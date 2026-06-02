// Accueil contrôleur : liste des stations avec leur état, accès inspection.
import React, { useCallback, useState } from "react";
import { View, Text, ScrollView, StyleSheet, TextInput, TouchableOpacity } from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import { supabase } from "@/lib/supabase";
import { useAuth } from "@/contexts/AuthContext";
import { BigButton, Card, EtatBadge } from "@/components/ui";
import { colors, spacing, fontSize } from "@/theme";

export default function ControleurHome({ navigation }: any) {
  const { signOut } = useAuth();
  const [stations, setStations] = useState<any[]>([]);
  const [q, setQ] = useState("");

  const charger = useCallback(async () => {
    const { data } = await supabase.from("v_carte_stations").select("*").order("nom");
    setStations(data ?? []);
  }, []);

  useFocusEffect(useCallback(() => { charger(); }, [charger]));

  const filtered = stations.filter((s) =>
    (s.nom + s.code + (s.region ?? "")).toLowerCase().includes(q.toLowerCase()),
  );

  return (
    <ScrollView style={s.container}>
      <TextInput style={s.search} placeholder="Rechercher une station…" value={q} onChangeText={setQ} />

      {filtered.map((st) => (
        <TouchableOpacity key={st.id} onPress={() => navigation.navigate("Inspection", { station: st })}>
          <Card>
            <View style={s.row}>
              <Text style={s.nom}>{st.nom}</Text>
              <EtatBadge etat={st.etat} />
            </View>
            <Text style={s.line}>{st.region} · {st.commune}</Text>
            <Text style={s.line}>Essence {Math.round(st.stock_essence)} L · Gasoil {Math.round(st.stock_gasoil)} L</Text>
            {st.alertes_ouvertes > 0 && (
              <Text style={[s.line, { color: colors.danger, fontWeight: "700" }]}>
                {st.alertes_ouvertes} alerte(s) ouverte(s)
              </Text>
            )}
          </Card>
        </TouchableOpacity>
      ))}

      <BigButton label="Se déconnecter" onPress={signOut} color={colors.muted} />
    </ScrollView>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.bg, padding: spacing.md },
  search: {
    backgroundColor: "#fff", borderWidth: 1, borderColor: colors.border, borderRadius: 10,
    padding: spacing.md, fontSize: fontSize.base, marginBottom: spacing.sm,
  },
  row: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  nom: { fontSize: fontSize.lg, fontWeight: "800", color: colors.text, flex: 1 },
  line: { color: colors.text, marginTop: spacing.xs },
});
