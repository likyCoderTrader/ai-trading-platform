-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.broker_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trade_signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_decision_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- PROFILES
CREATE POLICY "Users can view own profile" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- BROKER ACCOUNTS
CREATE POLICY "Users can view own broker accounts" 
ON public.broker_accounts FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own broker accounts" 
ON public.broker_accounts FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own broker accounts" 
ON public.broker_accounts FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own broker accounts" 
ON public.broker_accounts FOR DELETE 
USING (auth.uid() = user_id);

-- TRADE SIGNALS
CREATE POLICY "Users can view own trade signals" 
ON public.trade_signals FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own trade signals" 
ON public.trade_signals FOR UPDATE 
USING (auth.uid() = user_id);

-- TRADES
CREATE POLICY "Users can view own trades" 
ON public.trades FOR SELECT 
USING (auth.uid() = user_id);

-- AI DECISION LOG
CREATE POLICY "Users can view own ai decision log" 
ON public.ai_decision_log FOR SELECT 
USING (auth.uid() = user_id);

-- NOTIFICATIONS
CREATE POLICY "Users can view own notifications" 
ON public.notifications FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" 
ON public.notifications FOR UPDATE 
USING (auth.uid() = user_id);
