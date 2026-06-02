import React, { useState } from "react";
import { View, Text, TextInput, StyleSheet, KeyboardAvoidingView, Platform, Alert } from "react-native";
import { useAuth } from "@/contexts/AuthContext";
import { BigButton } from "@/components/ui";
import { colors, spacing, radius, fontSize } from "@/theme";

export default function LoginScreen() {
  const { signIn } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  async function onSubmit() {
    if (!email || !password) return Alert.alert("Champs requis", "Entrez votre identifiant et mot de passe.");
    setLoading(true);
    const { error } = await signIn(email.trim().toLowerCase(), password);
    setLoading(false);
    if (error) Alert.alert("Connexion échouée", error);
  }

  return (
    <KeyboardAvoidingView style={s.container} behavior={Platform.OS === "ios" ? "padding" : undefined}>
      <View style={s.header}>
        <Text style={s.logo}>SNTC</Text>
        <Text style={s.tagline}>Système National de Traçabilité des Carburants</Text>
      </View>

      <View style={s.form}>
        <Text style={s.label}>Identifiant</Text>
        <TextInput
          style={s.input} autoCapitalize="none" keyboardType="email-address"
          placeholder="email@sntc.ml" value={email} onChangeText={setEmail}
        />
        <Text style={s.label}>Mot de passe</Text>
        <TextInput
          style={s.input} secureTextEntry placeholder="••••••••"
          value={password} onChangeText={setPassword}
        />
        <BigButton label="Se connecter" onPress={onSubmit} loading={loading} color={colors.gold} />
      </View>

      <Text style={s.footer}>République du Mali · Ministère en charge de l'Énergie</Text>
    </KeyboardAvoidingView>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.navy, padding: spacing.lg, justifyContent: "center" },
  header: { alignItems: "center", marginBottom: spacing.xl },
  logo: { color: colors.gold, fontSize: 56, fontWeight: "900", letterSpacing: 4 },
  tagline: { color: "#fff", fontSize: fontSize.base, textAlign: "center", marginTop: spacing.sm },
  form: { backgroundColor: "#fff", borderRadius: radius.lg, padding: spacing.lg },
  label: { fontSize: fontSize.base, fontWeight: "700", color: colors.text, marginTop: spacing.sm },
  input: {
    borderWidth: 1, borderColor: colors.border, borderRadius: radius.md,
    padding: spacing.md, fontSize: fontSize.lg, marginTop: spacing.xs, marginBottom: spacing.sm,
  },
  footer: { color: "#fff", opacity: 0.7, textAlign: "center", marginTop: spacing.xl, fontSize: fontSize.sm },
});
