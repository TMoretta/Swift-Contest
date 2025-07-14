import { SeedPg } from "@snaplet/seed/adapter-pg";
import { defineConfig } from "@snaplet/seed/config";
import { Client } from "pg";

export default defineConfig({
  schema: ["public", "auth"],
  adapter: async () => {
    const client = new Client({
        connectionString: process.env.SUPABASE_DB_CONNECTION_STRING,
      });
    await client.connect();
    return new SeedPg(client);
  },
});