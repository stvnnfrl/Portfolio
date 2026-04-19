import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from typing import List

def standardize_columns(data_df, cols : List):
    for col in cols:
        mean = data_df[col].mean()
        std = data_df[col].std()
        data_df[col] = (data_df[col] - mean) / std
    return data_df

def one_hot_encode(data_df, cols : List):
    return pd.get_dummies(data_df, columns=cols, drop_first=False)

# 2.1
class LinearRegression:
    def __init__(self):
        self.w = None

    def fit(self, x_train, y_train):
        self.w = np.linalg.pinv(x_train) @ y_train

    def predict(self, x_test):
        return x_test @ self.w

# 2.3
def mean_squared_error(y_true, y_prediction):
    return np.mean((y_true - y_prediction) ** 2)

if __name__ == "__main__":
    # 1.1 and 1.2
    df = pd.read_csv("day.csv").drop(columns=["instant", "dteday"])
    # Use .isna() for mask, .any(axis=1) goes row by row to find True value
    # print(df[df.isna().any(axis=1)])
    # The result printed "Empty DataFrame", so no NaN values.

    df = standardize_columns(df, ["yr", "holiday", "workingday"])
    df = one_hot_encode(df, ["season", "mnth", "weekday", "weathersit"])

    """
    #1.3
    day_df = pd.read_csv("day.csv")
    time = day_df['instant']
    temperature = day_df['temp']
    feel_like_temperature = day_df['atemp']
    weather = day_df['weathersit']
    humidity = day_df['hum']
    windspeed = day_df['windspeed']
    season = day_df['season']

    casual = day_df['casual']
    registered = day_df['registered']
    cnt = day_df['cnt']

    fig, axs = plt.subplots(3, 2, figsize=(10, 8), sharex=True)

    # Time with Temp
    axs[0,0].plot(time , temperature, label="Temperature over time")
    axs[0,0].plot(time, feel_like_temperature, label="Feel-like temp. over time")
    axs[0,0].set_ylabel("Temperature")
    axs[0,0].set_title("Daily Temperature vs. Feels-like Temperature")
    axs[0,0].legend()

    # Time with Rental count
    axs[1,0].plot(time, casual, label="Casual rental")
    axs[1,0].plot(time, registered, label=" Registered rental")
    axs[1,0].plot(time, cnt, label="Total rental")
    axs[1,0].set_xlabel("Time")
    axs[1,0].set_ylabel("Count")
    axs[1,0].set_title("Bike rental over time")
    axs[1,0].legend()

    # Time with season
    axs[2,0].scatter(time, season, label="Season")
    axs[2,0].set_ylabel("Seasons")
    axs[2,0].set_title("Seasons over time")

    # Time with weather
    axs[0,1].scatter(time, weather, label="Weather over time")
    axs[0,1].set_ylabel("Weather")
    axs[0,1].set_title("Daily weather")

    # Time with humidity
    axs[1,1].scatter(time, humidity, label="Humidity over time")
    axs[1,1].set_ylabel("Humidity")
    axs[1,1].set_title("Daily humidity")

    # Time with windspeed
    axs[2,1].scatter(time, windspeed, label="Windspeed over time")
    axs[2,1].set_ylabel("Windspeed")
    axs[2,1].set_title("Daily windspeed")

    plt.tight_layout()
    plt.show()
    """

    # 2.1
    X = df.drop(columns=["casual", "registered", "cnt"])

    X = X.apply(pd.to_numeric)

    # Convert to np
    X_np: np.ndarray = X.to_numpy().astype(float)

    # Add bias
    bias = np.ones((X_np.shape[0], 1))
    X_np = np.hstack([X_np, bias])

    y_np: np.ndarray = df["cnt"].to_numpy()

    # 2.2
    ratio = 0.8  # 80% train, 20% test
    seed = int(input("Input seed number (integer): "))

    # Choose data randomly
    np.random.seed(seed)
    indices = np.random.permutation(len(X_np))
    split = int(len(X_np) * ratio)

    train_idx = indices[:split]
    test_idx = indices[split:]

    X_train = X_np[train_idx]
    y_train = y_np[train_idx]

    X_test = X_np[test_idx]
    y_test = y_np[test_idx]

    # Train the model
    model = LinearRegression()
    model.fit(X_train, y_train)

    # Predict
    y_pred = model.predict(X_test)

    # Evaluate
    linear_feature_mse = mean_squared_error(y_test, y_pred)

    # 3.1
    # Add new features
    X["temp_hum"] = X["temp"] * X["hum"]
    X["workingday_temp"] = X["workingday"] * X["temp"]

    X["temp_square"] = X["temp"] ** 2
    X["atemp_square"] = X["atemp"] ** 2
    X["hum_square"] = X["hum"] ** 2

    # Convert to numpy
    X_np = X.to_numpy().astype(float)

    # Add bias
    bias = np.ones((X_np.shape[0], 1))
    X_np = np.hstack([X_np, bias])

    # Split using same indices
    X_train_eng = X_np[train_idx]
    y_train_eng = y_np[train_idx]

    X_test_eng = X_np[test_idx]
    y_test_eng = y_np[test_idx]

    # Train new model
    model_eng = LinearRegression()
    model_eng.fit(X_train_eng, y_train_eng)

    # Predict
    y_pred_eng = model_eng.predict(X_test_eng)

    # Evaluate
    engineered_mse = mean_squared_error(y_test_eng, y_pred_eng)

    print(f"MSE with original features: {linear_feature_mse: .2f}")
    print(f"MSE with engineered features: {engineered_mse: .2f}")



