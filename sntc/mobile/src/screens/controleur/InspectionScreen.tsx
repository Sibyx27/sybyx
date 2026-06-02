// Inspection terrain : relevé de stock constaté, photo, rapport, infraction.
import React, { useState } from "react";
import { View, Text, TextInput, StyleSheet, Alert, ScrollView, Image, Switch } from "react-native";
import * as ImagePicker from "expo-image-picker";
import { supabase } from "@/lib/supabase";
import { useAuth } from "@/contexts/AuthContext";
import { BigButton, Card } from "@/components/ui";
import { colors, spacing, radius, fontSize } from "@/theme";

const MOTIFS = [
  "Rétention volontaire de carburant",
  "Vente spéculative",
  "Vente hors circuit",
  "Détournement de stock",
  "Écart de stock injustifié",
];

export default function InspectionScreen({ route, navigation }: any) {
  const { station } = route.params;
  const { profile } = useAuth();
  const [essence, setEssence] = useState("");
  const [gasoil, setGasoil] = useState("");
  const [rapport, setRapport] = useState("");
  const [photoUri, setPhotoUri] = useState<string | null>(null);
  const [infraction, setInfraction] = useState(false);
  const [motif, setMotif] = useState(MOTIFS[0]);
  const [gravite, setGravite] = useState<"mineure" | "majeure" | "grave">("majeure");
  const [saving, setSaving] = useState(false);

  async function photo() {
    const { status } = await ImagePicker.requestCameraPermissionsAsync();
    if (status !== "granted") return;
    const res = await ImagePicker.launchCameraAsync({ quality: 0.5 });
    if (!res.canceled) setPhotoUri(res.assets[0].uri);
  }

  async function enregistrer() {
    setSaving(true);
    try {
      const { data: insp, error } = await supabase
        .from("inspections")
        .insert({
          station_id: station.id,
          controleur_id: profile!.id,
          releve_essence: parseFloat(essence) || null,
          releve_gasoil: parseFloat(gasoil) || null,
          rapport,
        })
        .select("id")
        .single();
      if (error) throw error;

      if (photoUri) {
        const blob = await (await fetch(photoUri)).arrayBuffer();
        const path = `inspections/${insp.id}-${Date.now()}.jpg`;
        await supabase.storage.from("inspections").upload(path, blob, { contentType: "image/jpeg" });
        const url = supabase.storage.from("inspections").getPublicUrl(path).data.publicUrl;
        await supabase.from("inspection_photos").insert({ inspection_id: insp.id, photo_url: url });
      }

      if (infraction) {
        await supabase.from("infractions").insert({
          inspection_id: insp.id,
          station_id: station.id,
          controleur_id: profile!.id,
          gravite,
          motif,
          description: rapport,
        });
      }

      setSaving(false);
      Alert.alert("Inspection enregistrée", undefined, [{ text: "OK", onPress: () => navigation.goBack() }]);
    } catch (e: any) {
      setSaving(false);
      Alert.alert("Erreur", String(e?.message ?? e));
    }
  }

  return (
    <ScrollView style={s.container}>
      <Card><Text style={s.title}>{station.nom}</Text><Text style={s.muted}>{station.code}</Text></Card>

      <Text style={s.label}>Essence constatée (L)</Text>
      <TextInput style={s.input} keyboardType="decimal-pad" value={essence} onChangeText={setEssence} />
      <Text style={s.label}>Gasoil constaté (L)</Text>
      <TextInput style={s.input} keyboardType="decimal-pad" value={gasoil} onChangeText={setGasoil} />

      <Text style={s.label}>Rapport</Text>
      <TextInput style={[s.input, s.area]} multiline value={rapport} onChangeText={setRapport} placeholder="Observations…" />

      <BigButton label={photoUri ? "✓ Reprendre la photo" : "PRENDRE UNE PHOTO"} onPress={photo} />
      {photoUri && <Image source={{ uri: photoUri }} style={s.preview} />}

      <Card>
        <View style={s.row}><Text style={s.label}>Relever une infraction</Text><Switch value={infraction} onValueChange={setInfraction} /></View>
        {infraction && (
          <>
            <Text style={s.sub}>Motif</Text>
            {MOTIFS.map((m) => (
              <Text key={m} onPress={() => setMotif(m)} style={[s.choice, motif === m && s.choiceActive]}>{m}</Text>
            ))}
            <Text style={s.sub}>Gravité</Text>
            <View style={s.row}>
              {(["mineure", "majeure", "grave"] as const).map((g) => (
                <Text key={g} onPress={() => setGravite(g)} style={[s.tag, gravite === g && s.tagActive]}>{g}</Text>
              ))}
            </View>
          </>
        )}
      </Card>

      <BigButton label="ENREGISTRER L'INSPECTION" onPress={enregistrer} loading={saving} color={colors.gold} />
    </ScrollView>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.bg, padding: spacing.md },
  title: { fontSize: fontSize.lg, fontWeight: "800" },
  muted: { color: colors.muted },
  label: { fontSize: fontSize.base, fontWeight: "700", marginTop: spacing.md },
  sub: { fontWeight: "700", marginTop: spacing.sm },
  input: {
    backgroundColor: "#fff", borderWidth: 1, borderColor: colors.border, borderRadius: radius.md,
    fontSize: fontSize.lg, padding: spacing.md, marginTop: spacing.xs,
  },
  area: { minHeight: 90, textAlignVertical: "top" },
  preview: { width: "100%", height: 180, borderRadius: radius.md, marginTop: spacing.sm },
  row: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", gap: spacing.sm },
  choice: { padding: spacing.sm, borderRadius: 8, backgroundColor: "#fff", borderWidth: 1, borderColor: colors.border, marginTop: 4 },
  choiceActive: { backgroundColor: colors.navy, color: "#fff", borderColor: colors.navy },
  tag: { flex: 1, textAlign: "center", padding: spacing.sm, borderRadius: 8, backgroundColor: "#fff", borderWidth: 1, borderColor: colors.border, overflow: "hidden" },
  tagActive: { backgroundColor: colors.danger, color: "#fff", borderColor: colors.danger },
});
