// Accueil chauffeur : ses livraisons, validation de départ, accès au scan QR.
import React, { useCallback, useState } from "react";
import { View, Text, ScrollView, StyleSheet, Alert } from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import * as Location from "expo-location";
import { supabase } from "@/lib/supabase";
import { useAuth } from "@/contexts/AuthContext";
import { BigButton, Card, EtatBadge } from "@/components/ui";
import { colors, spacing, fontSize } from "@/theme";

const STATUT_LABEL: Record<string, string> = {
  creee: "À charger", depart_valide: "Départ validé", en_route: "En route",
  arrivee_validee: "Livrée", ecart_signale: "Écart signalé", annulee: "Annulée",
};

export default function ChauffeurHome({ navigation }: any) {
  const { signOut } = useAuth();
  const [livraisons, setLivraisons] = useState<any[]>([]);

  const charger = useCallback(async () => {
    const { data } = await supabase
      .from("livraisons")
      .select("*, stations(nom), depots(nom)")
      .in("statut", ["creee", "depart_valide", "en_route"])
      .order("created_at", { ascending: false });
    setLivraisons(data ?? []);
  }, []);

  useFocusEffect(useCallback(() => { charger(); }, [charger]));

  async function validerDepart(liv: any) {
    const { status } = await Location.requestForegroundPermissionsAsync();
    let coords: any = {};
    if (status === "granted") {
      const pos = await Location.getCurrentPositionAsync({});
      coords = { depart_lat: pos.coords.latitude, depart_lng: pos.coords.longitude };
    }
    const { error } = await supabase
      .from("livraisons")
      .update({ statut: "en_route", depart_le: new Date().toISOString(), ...coords })
      .eq("id", liv.id);
    if (error) return Alert.alert("Erreur", error.message);
    charger();
  }

  return (
    <ScrollView style={s.container}>
      {livraisons.length === 0 && <Text style={s.empty}>Aucune livraison en cours.</Text>}

      {livraisons.map((l) => (
        <Card key={l.id}>
          <View style={s.row}>
            <Text style={s.ref}>{l.reference}</Text>
            <EtatBadge etat={l.statut === "en_route" ? "faible" : l.statut === "creee" ? "inactive" : "normal"} />
          </View>
          <Text style={s.line}>{l.depots?.nom} → {l.stations?.nom}</Text>
          <Text style={s.line}>{l.produit.toUpperCase()} · {Math.round(l.volume_charge)} L · {STATUT_LABEL[l.statut]}</Text>

          {l.statut === "creee" && (
            <BigButton label="VALIDER LE DÉPART (GPS)" onPress={() => validerDepart(l)} />
          )}
          {(l.statut === "depart_valide" || l.statut === "en_route") && (
            <BigButton
              label="SCANNER QR & VALIDER ARRIVÉE"
              onPress={() => navigation.navigate("ValiderArrivee", { livraisonId: l.id, ref: l.reference })}
              color={colors.gold}
            />
          )}
        </Card>
      ))}

      <BigButton label="Se déconnecter" onPress={signOut} color={colors.muted} />
    </ScrollView>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.bg, padding: spacing.md },
  row: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  ref: { fontSize: fontSize.lg, fontWeight: "800", color: colors.text },
  line: { fontSize: fontSize.base, color: colors.text, marginTop: spacing.xs },
  empty: { textAlign: "center", color: colors.muted, marginTop: spacing.xl, fontSize: fontSize.base },
});
