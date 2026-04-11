-- USERS (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  email TEXT UNIQUE NOT NULL,
  subscription_tier TEXT DEFAULT 'free', -- free | pro | enterprise
  risk_profile JSONB DEFAULT '{
    "max_lot_size": 0.1,
    "max_daily_loss_pct": 2,
    "max_open_positions": 3,
    "drawdown_limit_pct": 10
  }',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- BROKER ACCOUNTS
CREATE TABLE public.broker_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  broker_name TEXT NOT NULL,          -- e.g. "Exness", "Binance"
  broker_type TEXT NOT NULL,          -- "mt5" | "api"
  account_label TEXT,
  encrypted_credentials BYTEA,        -- AES-256 encrypted JSON blob
  connection_status TEXT DEFAULT 'disconnected',
  balance NUMERIC(18,2),
  equity NUMERIC(18,2),
  currency TEXT DEFAULT 'USD',
  is_active BOOLEAN DEFAULT TRUE,
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TRADE SIGNALS (AI-generated recommendations)
CREATE TABLE public.trade_signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id),
  broker_account_id UUID REFERENCES public.broker_accounts(id),
  symbol TEXT NOT NULL,               -- e.g. "EURUSD", "BTCUSDT"
  direction TEXT NOT NULL,            -- "BUY" | "SELL" | "HOLD"
  entry_price_min NUMERIC(18,6),
  entry_price_max NUMERIC(18,6),
  stop_loss NUMERIC(18,6),
  take_profit_1 NUMERIC(18,6),
  take_profit_2 NUMERIC(18,6),
  take_profit_3 NUMERIC(18,6),
  confidence_score SMALLINT CHECK (confidence_score BETWEEN 0 AND 100),
  ai_explanation TEXT,                -- human-readable reasoning
  market_conditions JSONB,            -- indicators snapshot
  risk_considerations TEXT,
  invalidation_scenario TEXT,
  timeframe TEXT,                     -- "M15" | "H1" | "H4" | "D1"
  status TEXT DEFAULT 'pending',      -- pending | approved | rejected | expired
  expires_at TIMESTAMPTZ,
  generated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TRADES (executed orders)
CREATE TABLE public.trades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id),
  signal_id UUID REFERENCES public.trade_signals(id),
  broker_account_id UUID REFERENCES public.broker_accounts(id),
  broker_order_id TEXT,               -- ID returned by broker
  symbol TEXT NOT NULL,
  direction TEXT NOT NULL,
  lot_size NUMERIC(10,4),
  entry_price NUMERIC(18,6),
  stop_loss NUMERIC(18,6),
  take_profit NUMERIC(18,6),
  current_price NUMERIC(18,6),
  pnl NUMERIC(18,2),
  status TEXT DEFAULT 'open',         -- open | closed | cancelled
  opened_at TIMESTAMPTZ DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  close_reason TEXT                   -- "tp1" | "sl" | "manual" | "expired"
);

-- AI DECISION LOG (audit trail)
CREATE TABLE public.ai_decision_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  signal_id UUID REFERENCES public.trade_signals(id),
  user_id UUID REFERENCES public.profiles(id),
  raw_market_data JSONB,
  prompt_used TEXT,
  raw_ai_response TEXT,
  parsed_signal JSONB,
  model_used TEXT,
  tokens_used INTEGER,
  latency_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- NOTIFICATIONS
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id),
  type TEXT,  -- "new_signal" | "trade_opened" | "tp_hit" | "sl_hit" | "risk_alert"
  title TEXT,
  body TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
