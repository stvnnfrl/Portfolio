The code implements linear regression from scratch (NumPy) to predict daily bike rentals.

Data: Uses day.csv (Bike Sharing dataset)

Implementation:
1. The data is standardized and one-hot encoded, depending on the selected columns.
2. The linear regression model is implemented using pseudoinverse and MSE as evaluation metric.
3. The design matrix is augmented with interaction and polynomial features.

How to run: When the script is run, the console prompts the user to enter a random seed for the train/test split.

Output: Prints the MSE using the original featurs and the MSE using the engineered features.