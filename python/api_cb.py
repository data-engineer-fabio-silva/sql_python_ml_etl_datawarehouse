import requests
import json
from datetime import datetime

def get_coinbase_prices():
    """
    Fetch Bitcoin and USD stablecoin prices from Coinbase API
    """
    base_url = "https://api.coinbase.com/v2"
    
    # Define cryptocurrencies to fetch
    crypto_pairs = {
        "Bitcoin-Dólar": "BTC-USD",
        "Bitcoin-Real": "BTC-BRL",
        "Dólar-Real": "USD-BRL"
    }
    
    print(f"Fetching prices from Coinbase API...")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    print("-" * 60)
    
    results = {}
    
    for name, pair in crypto_pairs.items():
        try:
            # Fetch spot price
            endpoint = f"{base_url}/prices/{pair}/spot"
            response = requests.get(endpoint)
            response.raise_for_status()
            
            data = response.json()
            price = float(data['data']['amount'])
            currency = data['data']['currency']
            
            results[name] = {
                'price': price,
                'currency': currency,
                'pair': pair
            }
            
            print(f"{name:20} | R${price:,.6f} {currency}")
            
        except requests.exceptions.RequestException as e:
            print(f"{name:20} | Error: {str(e)}")
            results[name] = {'Error': str(e)}
        except KeyError as e:
            print(f"{name:20} | Error parsing response")
            results[name] = {'Error': 'Invalid response format'}
    
    print("-" * 60)
    
    return results

def get_exchange_rates():
    """
    Get current exchange rates from Coinbase
    """
    base_url = "https://api.coinbase.com/v2"
    
    try:
        endpoint = f"{base_url}/exchange-rates?currency=BTC"
        response = requests.get(endpoint)
        response.raise_for_status()
        
        data = response.json()
        rates = data['data']['rates']
        
        print("\nBitcoin Exchange Rates:")
        print("-" * 60)
        print(f"1 BTC = ${float(rates['USD']):,.2f} USD")
        # print(f"1 BTC = {float(rates['USDC']):,.2f} USDC")
        # print(f"1 BTC = {float(rates['USDT']):,.2f} USDT")
        print(f"1 BTC = {float(rates['BRL']):,.2f} BRL")

        
        return rates
        
    except Exception as e:
        print(f"Error fetching exchange rates: {str(e)}")
        return None

if __name__ == "__main__":
    # Fetch spot prices
    prices = get_coinbase_prices()
    
    # Fetch exchange rates
    # exchange_rates = get_exchange_rates()
    
    # Optional: Save to JSON file
    # output = {
    #     'timestamp': datetime.now().isoformat(),
    #     'prices': prices,
    #     'exchange_rates': exchange_rates
    # }
    
    # with open('coinbase_data.json', 'w') as f:
    #     json.dump(output, f, indent=2)
    
    # print(f"\n✓ Data saved to coinbase_data.json")