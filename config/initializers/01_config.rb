AUM = 20000000.0
MAX_PER_ENTRY = 1000000
MAX_NUMBER_OF_STOCKS = 30  # E.g. 30 long AND 30 short


COUNTRY = "AP"
INDEX_TICKER = 'HSI'
INDEX_NAME = 'Hong Kong Hang Seng Index'
CURRENCIES = ["USD", "SGD", "HKD", "CNY"]


# Fundamentals
LONG_ENTER_RANK_THRESHOLD  = 20
LONG_EXIT_RANK_THRESHOLD   = 30
SHORT_ENTER_RANK_THRESHOLD = 20
SHORT_EXIT_RANK_THRESHOLD  = 30


#Technicals
MA_LONG_ENTER  = false  # Use MA signal to enter long?
MA_LONG_EXIT   = false # Use MA signal to exit long?
MA_SHORT_ENTER = false  # Use MA signal to enter short?
MA_SHORT_EXIT  = false # Use MA signal to exit short?
MA = MA_LONG_ENTER or MA_LONG_EXIT or MA_SHORT_ENTER or MA_SHORT_EXIT 

RSI_OVERBOUGHT  = 70.0
RSI_OVERSOLD    = 35.0
RSI_LONG_ENTER  = false  # Use RSI signal to enter long?
RSI_LONG_EXIT   = false # Use RSI signal to exit long?
RSI_SHORT_ENTER = false  # Use RSI signal to enter long?
RSI_SHORT_EXIT  = false # Use RSI signal to exit short?
RSI = RSI_LONG_ENTER or RSI_LONG_EXIT or RSI_SHORT_ENTER or RSI_SHORT_EXIT 

TECHNICALS = MA or RSI


# Stop loss
LONG_STOP_LOSS = 0.1
SHORT_STOP_LOSS = 0.05
