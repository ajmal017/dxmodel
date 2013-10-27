AUM = 20000000.0
MAX_PER_ENTRY = 1000000
MAX_NUMBER_OF_STOCKS = 30  # E.g. 30 long AND 30 short


<<<<<<< HEAD
COUNTRY = "AU"
CURRENCIES = ["AUD", "NZD", "USD"]

# Index
INDEX_TICKER = "AS51"
INDEX_NAME = "ASX 200"
=======
COUNTRY = "AP"
INDEX_TICKER = 'HSI'
INDEX_NAME = 'Hong Kong Hang Seng Index'
CURRENCIES = ["USD", "SGD", "HKD", "CNY"]
>>>>>>> master


# Fundamentals
LONG_ENTER_RANK_THRESHOLD  = 20
LONG_EXIT_RANK_THRESHOLD   = 30
SHORT_ENTER_RANK_THRESHOLD = 20
SHORT_EXIT_RANK_THRESHOLD  = 30


#Technicals
MA = true
MA_LONG_ENTER  = true  # Use MA signal to enter long?
MA_LONG_EXIT   = false # Use MA signal to exit long?
MA_SHORT_ENTER = true  # Use MA signal to enter short?
MA_SHORT_EXIT  = false # Use MA signal to exit short?


RSI = false
<<<<<<< HEAD
RSI_OVERBOUGHT  = 70.0
RSI_OVERSOLD    = 35.0
RSI_LONG_ENTER  = false  # Use RSI signal to enter long?
RSI_LONG_EXIT   = false # Use RSI signal to exit long?
RSI_SHORT_ENTER = false  # Use RSI signal to enter long?
RSI_SHORT_EXIT  = false # Use RSI signal to exit short?
=======
#RSI_OVERBOUGHT  = 70.0
#RSI_OVERSOLD    = 35.0
#RSI_LONG_ENTER  = true  # Use RSI signal to enter long?
#RSI_LONG_EXIT   = false # Use RSI signal to exit long?
#RSI_SHORT_ENTER = true  # Use RSI signal to enter long?
#RSI_SHORT_EXIT  = false # Use RSI signal to exit short?
>>>>>>> master
