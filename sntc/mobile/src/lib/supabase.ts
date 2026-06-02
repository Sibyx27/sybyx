// Client Supabase configuré pour React Native + persistance sécurisée du token.
import "react-native-url-polyfill/auto";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { createClient } from "@supabase/supabase-js";
import Constants from "expo-constants";

const extra = Constants.expoConfig?.extra ?? {};
export const SUPABASE_URL = extra.supabaseUrl as string;
export const SUPABASE_ANON_KEY = extra.supabaseAnonKey as string;
export const MAPBOX_TOKEN = extra.mapboxToken as string;

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
  db: { schema: "sntc" },
});
