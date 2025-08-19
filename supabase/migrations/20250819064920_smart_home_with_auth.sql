-- Location: supabase/migrations/20250819064920_smart_home_with_auth.sql
-- Schema Analysis: Fresh Supabase project - no existing schema
-- Integration Type: Complete new schema for smart home controller
-- Dependencies: auth.users (Supabase provided)

-- 1. Create custom types
CREATE TYPE public.device_type AS ENUM ('light', 'fan', 'device', 'lock', 'thermostat', 'sensor', 'camera', 'speaker');
CREATE TYPE public.device_status AS ENUM ('online', 'offline', 'maintenance', 'error');
CREATE TYPE public.user_role AS ENUM ('admin', 'member', 'guest');
CREATE TYPE public.activity_type AS ENUM ('device_toggle', 'device_add', 'device_remove', 'device_rename', 'user_login', 'user_logout', 'system_update');

-- 2. Core tables
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'member'::public.user_role,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    device_type public.device_type NOT NULL,
    status public.device_status DEFAULT 'offline'::public.device_status,
    state BOOLEAN DEFAULT false,
    last_activity TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    device_identifier TEXT UNIQUE, -- For ESP32 MAC address or unique ID
    location TEXT,
    metadata JSONB DEFAULT '{}'::jsonb, -- For device-specific settings
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE CASCADE,
    activity_type public.activity_type NOT NULL,
    description TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_devices_user_id ON public.devices(user_id);
CREATE INDEX idx_devices_status ON public.devices(status);
CREATE INDEX idx_devices_device_type ON public.devices(device_type);
CREATE INDEX idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX idx_activity_logs_device_id ON public.activity_logs(device_id);
CREATE INDEX idx_activity_logs_created_at ON public.activity_logs(created_at);

-- 4. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

-- 5. Functions (must be created before RLS policies)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'member'::public.user_role)
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 6. RLS Policies
-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for devices
CREATE POLICY "users_manage_own_devices"
ON public.devices
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for activity logs
CREATE POLICY "users_manage_own_activity_logs"
ON public.activity_logs
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_devices_updated_at
    BEFORE UPDATE ON public.devices
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 8. Mock Data with complete auth users
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    device1_uuid UUID := gen_random_uuid();
    device2_uuid UUID := gen_random_uuid();
    device3_uuid UUID := gen_random_uuid();
    device4_uuid UUID := gen_random_uuid();
    device5_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields matching existing mock credentials
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@smarthome.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Johnson", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@smarthome.com', crypt('user123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Doe", "role": "member"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create devices
    INSERT INTO public.devices (id, user_id, name, device_type, status, state, last_activity, location, metadata) VALUES
        (device1_uuid, admin_uuid, 'Living Room Light', 'light'::public.device_type, 'online'::public.device_status, true, CURRENT_TIMESTAMP - INTERVAL '2 minutes', 'Living Room', '{"brightness": 75, "color": "warm_white"}'::jsonb),
        (device2_uuid, admin_uuid, 'Bedroom Fan', 'fan'::public.device_type, 'online'::public.device_status, false, CURRENT_TIMESTAMP - INTERVAL '15 minutes', 'Bedroom', '{"speed": 2, "timer": null}'::jsonb),
        (device3_uuid, admin_uuid, 'Kitchen Smart Plug', 'device'::public.device_type, 'online'::public.device_status, true, CURRENT_TIMESTAMP - INTERVAL '1 hour', 'Kitchen', '{"power_usage": 150}'::jsonb),
        (device4_uuid, admin_uuid, 'Front Door Lock', 'lock'::public.device_type, 'offline'::public.device_status, false, CURRENT_TIMESTAMP - INTERVAL '3 hours', 'Front Door', '{"auto_lock": true, "battery": 85}'::jsonb),
        (device5_uuid, admin_uuid, 'Thermostat', 'thermostat'::public.device_type, 'online'::public.device_status, true, CURRENT_TIMESTAMP - INTERVAL '30 minutes', 'Hallway', '{"temperature": 22, "target": 24, "mode": "heat"}'::jsonb);

    -- Create activity logs
    INSERT INTO public.activity_logs (user_id, device_id, activity_type, description, metadata) VALUES
        (admin_uuid, device1_uuid, 'device_toggle'::public.activity_type, 'Living Room Light turned ON', '{"previous_state": false, "new_state": true}'::jsonb),
        (admin_uuid, device2_uuid, 'device_toggle'::public.activity_type, 'Bedroom Fan turned OFF', '{"previous_state": true, "new_state": false}'::jsonb),
        (admin_uuid, device3_uuid, 'device_toggle'::public.activity_type, 'Kitchen Smart Plug turned ON', '{"previous_state": false, "new_state": true}'::jsonb),
        (admin_uuid, null, 'user_login'::public.activity_type, 'User logged in', '{"login_method": "email", "ip_address": "192.168.1.100"}'::jsonb);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;