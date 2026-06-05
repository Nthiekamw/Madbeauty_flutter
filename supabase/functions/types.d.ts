/** Types IDE pour les Edge Functions (runtime : Deno / Supabase). */
declare namespace Deno {
  namespace env {
    function get(key: string): string | undefined;
  }
}

interface Crypto {
  timingSafeEqual(a: Uint8Array, b: Uint8Array): boolean;
}

declare module "https://esm.sh/@supabase/supabase-js@2" {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  export function createClient(url: string, key: string): any;
}

declare module "google-auth-library" {
  export class JWT {
    constructor(options: {
      email: string;
      key: string;
      scopes?: string[];
    });
    getAccessToken(): Promise<{ token?: string | null }>;
  }
}
