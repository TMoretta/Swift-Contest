import { createSeedClient } from "@snaplet/seed";
import bcrypt from "bcryptjs";
import { v4 as uuidv4 } from "uuid";
import { faker } from "@faker-js/faker";

async function main() {
//   const seed = await createSeedClient({ dryRun: true });

  const seed = await createSeedClient();

//   await seed.$resetDatabase();

  const passwordHash = bcrypt.hashSync("123", 10);

  const usersIds = [
    "ignore",
    uuidv4(),
    uuidv4(),
    uuidv4(),
    uuidv4(),
  ];

  await seed.users([
    {
      instance_id: "00000000-0000-0000-0000-000000000000",
      id: usersIds[1],
      aud: "authenticated",
      role: "authenticated",
      email: "user1@example.com",
      encrypted_password: passwordHash,
      email_confirmed_at: new Date().toISOString(),
      invited_at: null,
      confirmation_token: "1",
      confirmation_sent_at: null,
      recovery_token: "1",
      recovery_sent_at: null,
      email_change_token_new: "1",
      email_change: "",
      email_change_sent_at: null,
      last_sign_in_at: null,
      raw_app_meta_data: {"provider": "email", "providers": ["email"]},
      raw_user_meta_data: {"email_verified": true},
      is_super_admin: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      phone: null,
      phone_confirmed_at: null,
      phone_change: "",
      phone_change_token: "1",
      phone_change_sent_at: null,
      email_change_token_current: "1",
      email_change_confirm_status: 0,
      banned_until: null,
      reauthentication_token: "1",
      reauthentication_sent_at: null,
      is_sso_user: false,
      deleted_at: null,
      is_anonymous: false,
    },
    {
      instance_id: "00000000-0000-0000-0000-000000000000",
      id: usersIds[2],
      aud: "authenticated",
      role: "authenticated",
      email: "user2@example.com",
      encrypted_password: passwordHash,
      email_confirmed_at: new Date().toISOString(),
      invited_at: null,
      confirmation_token: "2",
      confirmation_sent_at: null,
      recovery_token: "2",
      recovery_sent_at: null,
      email_change_token_new: "2",
      email_change: "",
      email_change_sent_at: null,
      last_sign_in_at: null,
      raw_app_meta_data: {"provider": "email", "providers": ["email"]},
      raw_user_meta_data: {"email_verified": true},
      is_super_admin: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      phone: null,
      phone_confirmed_at: null,
      phone_change: "",
      phone_change_token: "2",
      phone_change_sent_at: null,
      email_change_token_current: "2",
      email_change_confirm_status: 0,
      banned_until: null,
      reauthentication_token: "2",
      reauthentication_sent_at: null,
      is_sso_user: false,
      deleted_at: null,
      is_anonymous: false,
    },
    {
      instance_id: "00000000-0000-0000-0000-000000000000",
      id: usersIds[3],
      aud: "authenticated",
      role: "authenticated",
      email: "user3@example.com",
      encrypted_password: passwordHash,
      email_confirmed_at: new Date().toISOString(),
      invited_at: null,
      confirmation_token: "3",
      confirmation_sent_at: null,
      recovery_token: "3",
      recovery_sent_at: null,
      email_change_token_new: "3",
      email_change: "",
      email_change_sent_at: null,
      last_sign_in_at: null,
      raw_app_meta_data: {"provider": "email", "providers": ["email"]},
      raw_user_meta_data: {"email_verified": true},
      is_super_admin: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      phone: null,
      phone_confirmed_at: null,
      phone_change: "",
      phone_change_token: "3",
      phone_change_sent_at: null,
      email_change_token_current: "3",
      email_change_confirm_status: 0,
      banned_until: null,
      reauthentication_token: "3",
      reauthentication_sent_at: null,
      is_sso_user: false,
      deleted_at: null,
      is_anonymous: false,
    },
    {
      instance_id: "00000000-0000-0000-0000-000000000000",
      id: usersIds[4],
      aud: "authenticated",
      role: "authenticated",
      email: "user4@example.com",
      encrypted_password: passwordHash,
      email_confirmed_at: new Date().toISOString(),
      invited_at: null,
      confirmation_token: "4",
      confirmation_sent_at: null,
      recovery_token: "4",
      recovery_sent_at: null,
      email_change_token_new: "4",
      email_change: "",
      email_change_sent_at: null,
      last_sign_in_at: null,
      raw_app_meta_data: {"provider": "email", "providers": ["email"]},
      raw_user_meta_data: {"email_verified": true},
      is_super_admin: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      phone: null,
      phone_confirmed_at: null,
      phone_change: "",
      phone_change_token: "4",
      phone_change_sent_at: null,
      email_change_token_current: "4",
      email_change_confirm_status: 0,
      banned_until: null,
      reauthentication_token: "4",
      reauthentication_sent_at: null,
      is_sso_user: false,
      deleted_at: null,
      is_anonymous: false,
    },
  ]);

  await seed.identities([
    {
      provider_id: uuidv4(),
      user_id: usersIds[1],
      identity_data: {sub: usersIds[1], email: "user1@example.com", email_verified: true, phone_verified: false},
      provider: "email",
      last_sign_in_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
      updated_at:new Date().toISOString(),
    },
    {
      provider_id: uuidv4(),
      user_id: usersIds[2],
      identity_data: {sub: usersIds[2], email: "user2@example.com", email_verified: true, phone_verified: false},
      provider: "email",
      last_sign_in_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
      updated_at:new Date().toISOString(),
    },
    {
      provider_id: uuidv4(),
      user_id: usersIds[3],
      identity_data: {sub: usersIds[3], email: "user3@example.com", email_verified: true, phone_verified: false},
      provider: "email",
      last_sign_in_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
      updated_at:new Date().toISOString(),
    },
    {
      provider_id: uuidv4(),
      user_id: usersIds[4],
      identity_data: {sub: usersIds[4], email: "user4@example.com", email_verified: true, phone_verified: false},
      provider: "email",
      last_sign_in_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
      updated_at:new Date().toISOString(),
    },
  ]);

  const profilesIds = [
    "ignore",
    uuidv4(),
    uuidv4(),
    uuidv4(),
    uuidv4(),
  ];

  await seed.profiles([
    {
      id: profilesIds[1],
      user_id: usersIds[1],
      full_name: "User1",
      deleted_at: null,
      pref_role: "organizer",
    },
    {
      id: profilesIds[2],
      user_id: usersIds[2],
      full_name: "User2",
      deleted_at: null,
    },
    {
      id: profilesIds[3],
      user_id: usersIds[3],
      full_name: "User3",
      deleted_at: null,
    },
    {
      id: profilesIds[4],
      user_id: usersIds[4],
      full_name: "User4",
      deleted_at: null,
    },
  ]);

  await seed.contests([
    {
      organizer_id: profilesIds[1],
      date_time: new Date()
    },
    {
      organizer_id: profilesIds[1],
    },
    {
      organizer_id: profilesIds[1],
    },
    {
      organizer_id: profilesIds[1],
    },
    {
      organizer_id: profilesIds[2],
    },
  ]);

  process.exit(0);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
