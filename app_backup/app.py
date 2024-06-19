import os
import sqlite3

from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from tempfile import mkdtemp
from werkzeug.security import check_password_hash, generate_password_hash

from helpers import apology, login_required, lookup, usd

# Configure application
app = Flask(__name__)

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""
    # db.execute("CREATE TABLE history (user_id INTEGER NOT NULL, symbol TEXT NOT NULL, shares INTEGER NOT NULL, transacted DATETIME DEFAULT CURRENT_TIMESTAMP, price NUMERIC NOT NULL)")
    history = db.execute(
        "SELECT symbol, SUM(shares) as shares, price FROM history WHERE user_id = :user_id GROUP BY symbol HAVING shares > 0", user_id=session["user_id"])
    cash_db = db.execute("SELECT cash FROM users WHERE id = :user_id", user_id=session["user_id"])

    if len(cash_db) == 0:
        cash = 10000
    else :
        cash = cash_db[0]["cash"]

    print(history)
    total = cash
    for row in history:
        quote = lookup(row["symbol"])
        if not quote:
            return apology('Not found')
        row["name"] = quote["name"]
        row["price"] = quote["price"]
        row["value"] = row["price"] * row["shares"]
        total += row["value"]

    return render_template("index.html", history=history, cash='${:,.2f}'.format(cash), total='${:,.2f}'.format(total))


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""
    if request.method == "POST":
        symbol = request.form.get("symbol").upper()
        shares = request.form.get("shares")
        if not symbol:
            return apology('There must be a symbol')
        if not shares or not shares.isdigit() or int(shares) <= 0:
            return apology('It has to be a positive number')

        quote = lookup(symbol)
        if quote is None:
            return apology('Symbol not found')

        # Look up if he has cash
        price = quote["price"]
        cost = int(shares) * price

        cash = db.execute("SELECT cash FROM users WHERE id = :user_id", user_id=session["user_id"])
        cash = cash[0]['cash']
        if cash < cost:
            return apology("insufficient funds", 403)

        remains = cash - cost
        # update cash balance in users table
        db.execute("UPDATE users SET cash = :remains WHERE id = :user_id",
                   remains=remains, user_id=session["user_id"])

        # update history table
        # db.execute("CREATE TABLE history (user_id int,symbol varchar(255),shares int,method varchar(255),price int)")
        db.execute("INSERT INTO history (user_id, symbol, shares, price) VALUES (:user_id, :symbol, :shares, :price)",
                   user_id=session["user_id"], symbol=symbol, shares=shares, price='${:,.2f}'.format(price))

        return redirect("/")
    else:
        return render_template("buy.html")


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    rows = db.execute("SELECT * FROM history WHERE user_id = :user_id ORDER BY transacted DESC", user_id=session["user_id"])
    return render_template("history.html", rows=rows)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":

        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute("SELECT * FROM users WHERE username = ?", request.form.get("username"))

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(rows[0]["hash"], request.form.get("password")):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    """Get stock quote."""
    if request.method == "POST":
        symbol = request.form.get("symbol")
        quote = lookup(symbol)
        if not quote:
            return apology("invalid stock symbol")

        return render_template("quoted.html", quote=quote)

    else:
        return render_template("quote.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    # db.execute("CREATE TABLE history (user_id INTEGER NOT NULL, symbol TEXT NOT NULL, shares INTEGER NOT NULL, transacted DATETIME DEFAULT CURRENT_TIMESTAMP, price NUMERIC NOT NULL)")
    session.clear()
    if request.method == "POST":
        if not request.form.get("username"):
            return apology('provide username')
        elif not request.form.get("password"):
            return apology('provide a password')
        elif request.form.get("password") != request.form.get("confirmation"):
            return apology('password must be equal')

        username = request.form.get("username")
        password = request.form.get("password")

        dbName = db.execute("SELECT * FROM users WHERE username = :username", username=username)
        if len(dbName) != 0:
            return apology("username is already taken", 400)
        else:
            hashPassword = generate_password_hash(password)
            db.execute("INSERT INTO users (username, hash) VALUES (?, ?)", username, hashPassword)

            rows = db.execute("SELECT * FROM users WHERE username = ?", username)
            session["user_id"] = rows[0]["id"]

            # Redirect user to home page
            return redirect("/")
    else:
        return render_template("register.html")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""
    rows = db.execute(
        "SELECT symbol, SUM(shares) as shares FROM history WHERE user_id = :user_id GROUP BY symbol HAVING shares > 0", user_id=session["user_id"])

    # if GET method, render sell.html form
    if request.method == "GET":
        return render_template("sell.html", rows=rows)

    # if POST method, sell stock
    else:
        # save stock symbol, number of shares, and quote dict from form
        symbol = request.form.get("symbol")
        shares = request.form.get("shares")

        if not symbol:
            return apology("must provide number of shares")
        if not shares:
            return apology("must provide number of shares")
        else:
            shares = int(shares)

        for row in rows:
            if row["symbol"] == symbol:
                if row["shares"] < shares:
                    return apology("Not enought shares")
                else:
                    quote = lookup(symbol)
                    if quote == None:
                        return apology("Not found")
                    total = shares * quote["price"]
                    db.execute("UPDATE users SET cash = cash + :total WHERE id = :user_id", total=total, user_id=session["user_id"])

                    db.execute("INSERT INTO history (user_id, symbol, shares, price) VALUES (:user_id, :symbol, :shares, :price)",
                               user_id=session["user_id"], symbol=symbol, shares=-shares, price=usd(quote['price']))
                    return redirect("/")

        return apology("symbol not found")

if __name__ == '__main__':
    app.run(host='0.0.0.0')