import csv
import datetime
import pytz
import requests
import subprocess
import urllib
import uuid
import json

from flask import redirect, render_template, session
from functools import wraps


def apology(message, code=400):
    """Render message as an apology to user."""
    def escape(s):
        """
        Escape special characters.

        https://github.com/jacebrowning/memegen#special-characters
        """
        for old, new in [("-", "--"), (" ", "-"), ("_", "__"), ("?", "~q"),
                         ("%", "~p"), ("#", "~h"), ("/", "~s"), ("\"", "''")]:
            s = s.replace(old, new)
        return s
    return render_template("apology.html", top=code, bottom=escape(message)), code


def login_required(f):
    """
    Decorate routes to require login.

    http://flask.pocoo.org/docs/0.12/patterns/viewdecorators/
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if session.get("user_id") is None:
            return redirect("/login")
        return f(*args, **kwargs)
    return decorated_function


def lookup(symbol):
    """Look up quote for symbol."""
    # Prepare API request
    symbol = symbol.upper()

    url = (
        f"https://api.twelvedata.com/avgprice"
        f"?symbol={urllib.parse.quote_plus(symbol)}"
        f"&outputsize=1&dp=2"
        f"&interval=1min&apikey=75311c3acfba42ed8ed6007545345c75"
    )

    # Query API
    try:
        response = requests.get(url).json()
        quotes = response.get('values')
        obj = quotes[0].get('avgprice')
        
        price = round(float(obj), 2)

        return {
            "name": symbol,
            "price": price,
            "symbol": symbol
        }
    except (requests.RequestException, ValueError, KeyError, IndexError):
        return None


def usd(value):
    """Format value as USD."""
    return f"${value:,.2f}"