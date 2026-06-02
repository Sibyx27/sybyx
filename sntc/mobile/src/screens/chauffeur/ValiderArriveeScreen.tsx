// Validation d'arrivée : scan du QR Code, photo horodatée obligatoire, GPS,
// volume reçu. Appelle l'edge function `valider-arrivee` (vérif token + géofence).
import React, { useState } from "react";
import { View, Text, TextInput, StyleSheet, Alert, Image } from "react-native";
import { BarCodeScanner } from "expo-barcode-scanner";
import * as Location from "expo-location";
import * as ImagePicker from "expo-image-picker";
import { supabase, SUPABASE_URL, SUPABASE_ANON_KEY } from "@/lib/supabase";
import { BigButton, Card } from "@/components/ui";
import { colors, spacing, radius, fontSize } from "@/theme";

export default function ValiderArriveeScreen({ route, navigation }: any) {
  const { ref } = route.params;
  const [hasPerm, setHasPerm] = useState<boolean | null>(null);
  const [qrToken, setQrToken] = useState<string | null>(null);
  const [scanning, setScanning] = useState(true);
  const [volume, setVolume] = useState("");
  const [photoUri, setPhotoUri] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  React.useEffect(() => {
    BarCodeScanner.requestPermissionsAsync().then(({ status }) => setHasPerm(status === "granted"));
  }, []);

  function onScan({ data }: { data: string }) {
    try {
      const parsed = JSON.parse(data); // { r: reference, t: token }
      if (parsed.r !== ref) {
        return Alert.alert("QR incorrect", `Ce QR correspond à ${parsed.r}, attendu ${ref}.`);
      }
      setQrToken(parsed.t);
      setScanning(false);
    } catch {
      Alert.alert("QR illisible", "Le QR Code n'est pas un bon de livraison SNTC valide.");
    }
  }

  async function prendrePhoto() {
    const { status } = await ImagePicker.requestCameraPermissionsAsync();
    if (status !== "granted") return Alert.alert("Caméra refusée");
    const res = await ImagePicker.launchCameraAsync({ quality: 0.5, exif: false });
    if (!res.canceled) setPhotoUri(res.assets[0].uri);
  }

  async function uploadPhoto(uri: string): Promise<string> {
    const resp = await fetch(uri);
    const blob = await resp.arrayBuffer();
    const path = `arrivees/${ref}-${Date.now()}.jpg`;
    const { error } = await supabase.storage.from("livraisons").upload(path, blob, { contentType: "image/jpeg" });
    if (error) throw error;
    return supabase.storage.from("livraisons").getPublicUrl(path).data.publicUrl;
  }

  async function valider() {
    if (!qrToken) return Alert.alert("Scannez d'abord le QR Code.");
    if (!photoUri) return Alert.alert("Photo obligatoire", "Prenez une photo horodatée de la livraison.");
    const v = parseFloat(volume.replace(",", "."));
    if (!v || v <= 0) return Alert.alert("Volume reçu invalide");

    setSubmitting(true);
    try {
      const photo_url = await uploadPhoto(photoUri);
      const { status } = await Location.requestForegroundPermissionsAsync();
      let lat: number | null = null, lng: number | null = null;
      if (status === "granted") {
        const pos = await Location.getCurrentPositionAsync({});
        lat = pos.coords.latitude; lng = pos.coords.longitude;
      }

      const { data: { session } } = await supabase.auth.getSession();
      const r = await fetch(`${SUPABASE_URL}/functions/v1/valider-arrivee`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          apikey: SUPABASE_ANON_KEY,
          Authorization: `Bearer ${session?.access_token}`,
        },
        body: JSON.stringify({ qr_token: qrToken, volume_recu: v, latitude: lat, longitude: lng, photo_url }),
      });
      const out = await r.json();
      setSubmitting(false);
      if (!r.ok) return Alert.alert("Échec", out.error ?? "Erreur");
      Alert.alert("Arrivée validée", out.message, [{ text: "OK", onPress: () => navigation.goBack() }]);
    } catch (e: any) {
      setSubmitting(false);
      Alert.alert("Erreur", String(e?.message ?? e));
    }
  }

  if (hasPerm === false) return <Text style={s.info}>Accès caméra refusé.</Text>;

  if (scanning) {
    return (
      <View style={s.scanner}>
        <BarCodeScanner onBarCodeScanned={onScan} style={StyleSheet.absoluteFillObject} />
        <View style={s.scanOverlay}><Text style={s.scanText}>Scannez le QR du bon de livraison {ref}</Text></View>
      </View>
    );
  }

  return (
    <View style={s.container}>
      <Card><Text style={s.ok}>✓ QR validé pour {ref}</Text></Card>

      <Text style={s.label}>Volume reçu (litres)</Text>
      <TextInput style={s.input} keyboardType="decimal-pad" value={volume} onChangeText={setVolume} />

      <BigButton label={photoUri ? "✓ Reprendre la photo" : "PRENDRE LA PHOTO"} onPress={prendrePhoto} />
      {photoUri && <Image source={{ uri: photoUri }} style={s.preview} />}

      <BigButton label="VALIDER L'ARRIVÉE" onPress={valider} loading={submitting} color={colors.gold} />
    </View>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.bg, padding: spacing.md },
  scanner: { flex: 1, backgroundColor: "#000" },
  scanOverlay: { position: "absolute", bottom: 60, left: 0, right: 0, alignItems: "center" },
  scanText: { color: "#fff", backgroundColor: "rgba(0,0,0,0.6)", padding: spacing.md, fontSize: fontSize.base },
  ok: { color: colors.vert, fontWeight: "800", fontSize: fontSize.lg },
  label: { fontSize: fontSize.base, fontWeight: "700", marginTop: spacing.md },
  input: {
    backgroundColor: "#fff", borderWidth: 2, borderColor: colors.navy, borderRadius: radius.md,
    fontSize: fontSize.xl, fontWeight: "800", textAlign: "center", padding: spacing.md, marginTop: spacing.sm,
  },
  preview: { width: "100%", height: 200, borderRadius: radius.md, marginTop: spacing.sm },
  info: { padding: spacing.lg, fontSize: fontSize.base },
});
