--region ROW LEVEL SECURITY FOR PROFILES
-- Enable Row Level Security on the profiles table.
-- This is a critical security measure to protect user data.
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to ensure a clean state before creating new ones.
DROP POLICY IF EXISTS "Allow authenticated users to read profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow users to update their own profile" ON public.profiles;

--region SELECT POLICY
-- Allow any authenticated user to read profile information.
-- This is necessary for features like displaying an organizer's name on a contest page.
-- Anonymous users are blocked by default.
CREATE POLICY "Allow authenticated users to read profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (true); -- Equivalent to auth.role() = 'authenticated'
--endregion

--region UPDATE POLICY
-- Allow a user to update ONLY their own profile.
-- The `USING` clause determines which rows can be updated.
-- The `WITH CHECK` clause ensures that an update cannot change the row's ownership.
CREATE POLICY "Allow users to update their own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
--endregion

--region COLUMN-LEVEL PERMISSIONS FOR UPDATE
-- By default, no columns are updatable. We must explicitly grant permission
-- for the columns that users are allowed to change.
-- This prevents users from modifying critical fields like 'id' or 'created_at'.
-- Revoke all update permissions first for a clean slate.
REVOKE UPDATE ON public.profiles FROM authenticated;
-- Grant update permission only on specific, safe-to-modify columns.
GRANT UPDATE (full_name, pref_role) ON public.profiles TO authenticated;
--endregion

-- NOTE: No INSERT or DELETE policies are needed for users.
-- INSERT is handled by a trigger on new user sign-up.
-- DELETE is handled by a CASCADE from the auth.users table.
--endregion