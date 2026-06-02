// Design tokens — interface volontairement simple, gros boutons, fort contraste.
export const colors = {
  navy: "#0E2240",
  gold: "#C8A24B",
  white: "#FFFFFF",
  bg: "#F4F6F9",
  text: "#1A1A1A",
  muted: "#6B7280",
  border: "#E2E6EC",
  // Couleurs d'état des stations (carte nationale)
  vert: "#1E9E5A",
  jaune: "#E8B500",
  rouge: "#D33A2C",
  noir: "#2B2B2B",
  danger: "#D33A2C",
};

export const etatColor: Record<string, string> = {
  normal: colors.vert,
  faible: colors.jaune,
  rupture: colors.rouge,
  inactive: colors.noir,
};

export const spacing = { xs: 6, sm: 10, md: 16, lg: 24, xl: 32 };
export const radius = { sm: 8, md: 14, lg: 20 };

// Boutons généreux pour usage terrain (gants, plein soleil, urgence)
export const fontSize = { sm: 14, base: 17, lg: 22, xl: 30, xxl: 40 };
