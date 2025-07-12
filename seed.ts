import { createSeedClient } from "@snaplet/seed";
import bcrypt from "bcryptjs";
import { v4 as uuidv4 } from "uuid";
import { faker } from "@faker-js/faker";

async function main() {
  //   const seed = await createSeedClient({ dryRun: true });
  const seed = await createSeedClient();

  //   await seed.$resetDatabase();

  const passwordHash = bcrypt.hashSync("123", 10);
  await seed.users((x) => x(2, {
    instance_id: "00000000-0000-0000-0000-000000000000",
    id: uuidv4(),
    aud: "authenticated",
    role: "authenticated",
    email: faker.internet.email,
    encrypted_password: passwordHash,
    email_confirmed_at: new Date().toISOString(),
    invited_at: null,
    confirmation_token: null,
    confirmation_sent_at: null,
    recovery_token: null,
    recovery_sent_at: null,
    email_change_token_new: null,
    email_change: null,
    email_change_sent_at: null,
    last_sign_in_at: null,
    raw_app_meta_data: { provider: "email", providers: ["email"] },
    raw_user_meta_data: { email_verified: true },
    is_super_admin: false,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    phone: null,
    phone_confirmed_at: null,
    phone_change: null,
    phone_change_token: null,
    phone_change_sent_at: null,
    email_change_token_current: null,
    email_change_confirm_status: 0,
    banned_until: null,
    reauthentication_token: null,
    reauthentication_sent_at: null,
    is_sso_user: false,
    deleted_at: null,
    is_anonymous: false
  }));


//   var currentSeed = await seed.users((x) =>
//     x(5, (i) => {
//       const passwordHash = bcrypt.hashSync("123", 10);
//       return {
//         instance_id: "00000000-0000-0000-0000-000000000000",
//         id: uuidv4(),
//         aud: "authenticated",
//         role: "authenticated",
//         email: faker.internet.email,
//         encrypted_password: passwordHash,
//         email_confirmed_at: new Date().toISOString(),
//         invited_at: null,
//         confirmation_token: null,
//         confirmation_sent_at: null,
//         recovery_token: null,
//         recovery_sent_at: null,
//         email_change_token_new: null,
//         email_change: null,
//         email_change_sent_at: null,
//         last_sign_in_at: null,
//         raw_app_meta_data: { provider: "email", providers: ["email"] },
//         raw_user_meta_data: { email_verified: true },
//         is_super_admin: false,
//         created_at: new Date().toISOString(),
//         updated_at: new Date().toISOString(),
//         phone: null,
//         phone_confirmed_at: null,
//         phone_change: null,
//         phone_change_token: null,
//         phone_change_sent_at: null,
//         email_change_token_current: null,
//         email_change_confirm_status: 0,
//         banned_until: null,
//         reauthentication_token: null,
//         reauthentication_sent_at: null,
//         is_sso_user: false,
//         deleted_at: null,
//         is_anonymous: false
//       };
//     })
//   );
//
//   var currentSeed = seed.;
//
//   console.log(currentSeed);
//
//   const users = currentSeed.users;
//
//   for (let i = 0; i < users.length; i++) {
//     await seed
//   }
//
//   // 4) Seed dei profili, uno per ogni utente
//   seed.users()
//   await seed.profiles((x) =>
//     x(usersNumber, (i) => ({
//       id: uuidv4(),
//       created_at: new Date().toISOString(),
//       user_id: users[i].id,
//       full_name: faker.name.findName(),
//       pref_role: faker.helpers.arrayElement(["organizer", "participant", "juror"]),
//       // …qualsiasi altro campo di profiles…
//     }))
//   );

  process.exit(0);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
