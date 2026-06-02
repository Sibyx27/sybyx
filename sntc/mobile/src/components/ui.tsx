// Composants UI partagés : gros boutons, cartes, badges d'état.
import React from "react";
import { Text, TouchableOpacity, View, StyleSheet, ActivityIndicator } from "react-native";
import { colors, radius, spacing, fontSize, etatColor } from "@/theme";

export function BigButton({
  label, onPress, color = colors.navy, disabled, loading,
}: {
  label: string; onPress: () => void; color?: string; disabled?: boolean; loading?: boolean;
}) {
  return (
    <TouchableOpacity
      style={[s.btn, { backgroundColor: disabled ? colors.muted : color }]}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.85}
    >
      {loading ? <ActivityIndicator color="#fff" /> : <Text style={s.btnText}>{label}</Text>}
    </TouchableOpacity>
  );
}

export function Card({ children, style }: { children: React.ReactNode; style?: object }) {
  return <View style={[s.card, style]}>{children}</View>;
}

export function EtatBadge({ etat }: { etat: string }) {
  const labels: Record<string, string> = {
    normal: "Normal", faible: "Faible", rupture: "Rupture", inactive: "Inactive",
  };
  return (
    <View style={[s.badge, { backgroundColor: etatColor[etat] ?? colors.muted }]}>
      <Text style={s.badgeText}>{labels[etat] ?? etat}</Text>
    </View>
  );
}

export function Stat({ label, value, color = colors.navy }: { label: string; value: string; color?: string }) {
  return (
    <View style={s.stat}>
      <Text style={[s.statValue, { color }]}>{value}</Text>
      <Text style={s.statLabel}>{label}</Text>
    </View>
  );
}

const s = StyleSheet.create({
  btn: {
    paddingVertical: spacing.lg, borderRadius: radius.md, alignItems: "center",
    marginVertical: spacing.sm, minHeight: 64, justifyContent: "center",
  },
  btnText: { color: "#fff", fontSize: fontSize.lg, fontWeight: "700" },
  card: {
    backgroundColor: "#fff", borderRadius: radius.md, padding: spacing.md,
    marginVertical: spacing.sm, borderWidth: 1, borderColor: colors.border,
  },
  badge: { paddingHorizontal: spacing.sm, paddingVertical: 4, borderRadius: radius.sm, alignSelf: "flex-start" },
  badgeText: { color: "#fff", fontWeight: "700", fontSize: fontSize.sm },
  stat: { flex: 1, alignItems: "center", padding: spacing.sm },
  statValue: { fontSize: fontSize.xl, fontWeight: "800" },
  statLabel: { fontSize: fontSize.sm, color: colors.muted, textAlign: "center", marginTop: 2 },
});
