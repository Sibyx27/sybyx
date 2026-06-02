// =============================================================================
// SNTC — Point d'entrée : routage par rôle
// =============================================================================
import React, { useEffect } from "react";
import { ActivityIndicator, View } from "react-native";
import { StatusBar } from "expo-status-bar";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { SafeAreaProvider } from "react-native-safe-area-context";

import { AuthProvider, useAuth } from "@/contexts/AuthContext";
import { startAutoSync } from "@/lib/offline";
import { colors } from "@/theme";

import LoginScreen from "@/screens/LoginScreen";
import GerantHome from "@/screens/gerant/GerantHome";
import VenteRapideScreen from "@/screens/gerant/VenteRapideScreen";
import StockScreen from "@/screens/gerant/StockScreen";
import ChauffeurHome from "@/screens/chauffeur/ChauffeurHome";
import ValiderArriveeScreen from "@/screens/chauffeur/ValiderArriveeScreen";
import ControleurHome from "@/screens/controleur/ControleurHome";
import InspectionScreen from "@/screens/controleur/InspectionScreen";
import AdminHome from "@/screens/admin/AdminHome";

const Stack = createNativeStackNavigator();

function Router() {
  const { session, profile, loading } = useAuth();

  useEffect(() => {
    if (!session) return;
    const stop = startAutoSync();
    return stop;
  }, [session]);

  if (loading) {
    return (
      <View style={{ flex: 1, justifyContent: "center", backgroundColor: colors.bg }}>
        <ActivityIndicator size="large" color={colors.navy} />
      </View>
    );
  }

  const screenOptions = {
    headerStyle: { backgroundColor: colors.navy },
    headerTintColor: "#fff",
    headerTitleStyle: { fontWeight: "700" as const },
  };

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={screenOptions}>
        {!session || !profile ? (
          <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
        ) : profile.role === "gerant" ? (
          <>
            <Stack.Screen name="GerantHome" component={GerantHome} options={{ title: "Ma station" }} />
            <Stack.Screen name="VenteRapide" component={VenteRapideScreen} options={{ title: "Saisie vente" }} />
            <Stack.Screen name="Stock" component={StockScreen} options={{ title: "Relevé de stock" }} />
          </>
        ) : profile.role === "chauffeur" ? (
          <>
            <Stack.Screen name="ChauffeurHome" component={ChauffeurHome} options={{ title: "Mes livraisons" }} />
            <Stack.Screen name="ValiderArrivee" component={ValiderArriveeScreen} options={{ title: "Valider l'arrivée" }} />
          </>
        ) : profile.role === "controleur" ? (
          <>
            <Stack.Screen name="ControleurHome" component={ControleurHome} options={{ title: "Inspections" }} />
            <Stack.Screen name="Inspection" component={InspectionScreen} options={{ title: "Nouvelle inspection" }} />
          </>
        ) : (
          <Stack.Screen name="AdminHome" component={AdminHome} options={{ title: "Tableau de bord national" }} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <AuthProvider>
        <StatusBar style="light" />
        <Router />
      </AuthProvider>
    </SafeAreaProvider>
  );
}
