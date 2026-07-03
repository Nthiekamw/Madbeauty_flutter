import { createClient, type SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export function serviceClient(): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !key) {
    throw new Error("SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY manquant");
  }
  return createClient(url, key);
}

export function userClient(authHeader: string): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL");
  const anon = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !anon) {
    throw new Error("SUPABASE_URL ou SUPABASE_ANON_KEY manquant");
  }
  return createClient(url, anon, {
    global: { headers: { Authorization: authHeader } },
  });
}

export async function requireAuthUser(req: Request) {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    throw new Response(JSON.stringify({ error: "Non authentifié" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }
  const supabase = userClient(authHeader);
  const { data, error } = await supabase.auth.getUser();
  if (error || !data.user) {
    throw new Response(JSON.stringify({ error: "Session invalide" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }
  return { supabase, user: data.user, authHeader };
}
