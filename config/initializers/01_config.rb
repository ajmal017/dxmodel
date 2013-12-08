AUM = 20000000.0
MAX_PER_ENTRY = 1000000
MAX_NUMBER_OF_STOCKS = 30  # E.g. 30 long AND 30 short


# Country
COUNTRY = "US"
CURRENCIES = ["USD"]

# Index
INDEX_TICKER = "INDU"
INDEX_NAME = "Dow Jones Industrial Average"


# Fundamentals
LONG_ENTER_RANK_THRESHOLD  = 20
LONG_EXIT_RANK_THRESHOLD   = 75
SHORT_ENTER_RANK_THRESHOLD = 20
SHORT_EXIT_RANK_THRESHOLD  = 75


#Technicals
MA_LONG_ENTER  = true  # Use MA signal to enter long?
MA_LONG_EXIT   = false # Use MA signal to exit long?
MA_SHORT_ENTER = true  # Use MA signal to enter short?
MA_SHORT_EXIT  = false # Use MA signal to exit short?
MA = MA_LONG_ENTER or MA_LONG_EXIT or MA_SHORT_ENTER or MA_SHORT_EXIT 


RSI_OVERBOUGHT  = 70.0
RSI_OVERSOLD    = 35.0
RSI_LONG_ENTER  = true  # Use RSI signal to enter long?
RSI_LONG_EXIT   = false # Use RSI signal to exit long?
RSI_SHORT_ENTER = true  # Use RSI signal to enter long?
RSI_SHORT_EXIT  = false # Use RSI signal to exit short?
RSI = RSI_LONG_ENTER or RSI_LONG_EXIT or RSI_SHORT_ENTER or RSI_SHORT_EXIT 

TECHNICALS = MA or RSI


# Stop loss
LONG_STOP_LOSS = 0.1
SHORT_STOP_LOSS = 0.05
