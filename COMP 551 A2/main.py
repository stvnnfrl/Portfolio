# Importing useful libraries for this project
import numpy    as np
import pandas   as pd
import matplotlib.pyplot        as plt

from sklearn.model_selection    import KFold
from LogisticRegression         import LogisticRegression;
from sklearn.linear_model       import LogisticRegression as SklearnLogisticRegression, LogisticRegressionCV

# ------------------------------ Task 0: Preprocessing ----------------------------------------------
# In this section, we will load the data (found on https://archive.ics.uci.edu/dataset/94/spambase)
# Divide the dataset between features and output (57 continuous features, 1 binary output)

rng = np.random.default_rng(2026) # As requested by the assignment.

# Load the dataset and extract the features and output
data = np.loadtxt("spambase.data", delimiter=",").astype(float)
X = data[:, :-1]    # The features (all columns except last)
y = data[:,  -1]    # The outputs spam / not spam (last column)

# Randomize the dataset
indices = rng.permutation(len(data))    # Randomly generated row numbers (Shuffling data)
X, y = X[indices], y[indices]           # Replace the old features and outputs in randomized order

train_index = int(0.05 * len(X))        # 5% of the dataset used to train, 95% used to test

# Split the features and outputs between train and test
X_train, X_test = X[:train_index], X[train_index:]
y_train, y_test = y[:train_index], y[train_index:]

# Standardize
mu      = X_train.mean(axis=0)
sigma   = X_train.std(axis=0) + 1e-8  # Avoid division by zero

X_train = (X_train - mu) / sigma # Replace X_train by standardized form
X_test  = (X_test  - mu) / sigma # Replace X_test  by standardized form

# ---------------------------- Task 1: Logistic Regression with SGD ------------------------------
# # Convention choice for L2: λ * ||w||^2

# ---------- Deliverable Phase ----------
# In this section, we test the impact of each parameters on the learning capability 
#   of our Logistic Regression model.
# Different etas will cause a different regularization, different lambdas cause
#   a different learning rate, a change in the epochs will determine how many times
#   training our model is appropriate / necessary, and batch sizes determine
#   over how many samples we should go through to average out the Gradient. 

# d = X_train.shape[1]

# # For graphing later
# all_loss_histories = {}

# etas_plots          = [0.1, 0.01]   # Tested η
# lambdas_plots       = [0.0, 1e-3]   # Tested ƛ
# epochs_list_plots   = [50, 120]     # Tested epochs
# batch_sizes_plots   = [1, 16]       # Tested batch sizes

# def train_and_store(model, eta, lambda_, epochs, batch_size, histories):
#     model.reset() # Reset the computed weights from the previous test
#     model.fit(X_train, y_train, epochs=epochs, batch_size=batch_size)
#     key = f"eta{eta}_l2{lambda_}_epochs{epochs}_batch_size{batch_size}"
#     histories[key] = model.loss_history.copy() # Record observations to plot later

# for eta in etas_plots:
#     for lambda_ in lambdas_plots:
#         # Lambdas and etas are created during the LogisticRegression model.
#         model = LogisticRegression(d, eta=eta, lambda_=lambda_)
#         for epochs in epochs_list_plots:
#             # Testing out different epochs
#             for batch_size in batch_sizes_plots:
#                 # Testing out different batch_sizes 
#                 train_and_store(model, eta, lambda_, epochs, batch_size, all_loss_histories)

# # Plotting
# def plot_training_comparison(ax, key1, key2, loss_dict, title, label1="eta=0.1", label2="eta=0.01"):

#     # Plot two training loss curves on a given axes.

#     # ax        : matplotlib axes to plot on
#     # key1      : key for the first curve in loss_dict
#     # key2      : key for the second curve in loss_dict
#     # loss_dict : dictionary with all loss histories
#     # title     : subplot title
#     # label1    : legend label for first curve
#     # label2    : legend label for second curve

#     ax.plot(loss_dict[key1], label=label1)
#     ax.plot(loss_dict[key2], label=label2)

#     ax.set_title(title)
#     ax.set_xlabel("Epoch")
#     ax.set_ylabel("Training Loss")

#     ax.set_ylim(bottom=0)

#     ax.legend()
#     ax.grid(True)

# # No regularization
# fig1, axs1 = plt.subplots(2, 2, figsize=(12, 8))
# for i, epochs in enumerate(epochs_list_plots):
#     for j, batch_size in enumerate(batch_sizes_plots):
#         key1 = f"eta0.1_l2{0.0}_epochs{epochs}_batch_size{batch_size}"
#         key2 = f"eta0.01_l2{0.0}_epochs{epochs}_batch_size{batch_size}"
#         title = f"Epochs={epochs}, Batch={batch_size}, No Regularization"
#         plot_training_comparison(axs1[i][j], key1, key2, all_loss_histories, title)

# fig1.suptitle("Comparison of Training Loss (No Reg)")
# plt.tight_layout(rect=[0, 0.03, 1, 0.95])

# # L2 Regularization
# fig2, axs2 = plt.subplots(2, 2, figsize=(12, 8))
# for i, epochs in enumerate(epochs_list_plots):
#     for j, batch_size in enumerate(batch_sizes_plots):
#         key1 = f"eta0.1_l2{1e-3}_epochs{epochs}_batch_size{batch_size}"
#         key2 = f"eta0.01_l2{1e-3}_epochs{epochs}_batch_size{batch_size}"
#         title = f"Epochs={epochs}, Batch={batch_size}, L2 Regularization"
#         plot_training_comparison(axs2[i][j], key1, key2, all_loss_histories, title)

# fig2.suptitle("Comparison of Training Loss (With L2 Reg)")
# plt.tight_layout(rect=[0, 0.03, 1, 0.95])

# plt.show()

# ---------------------------- Task 2: Hyperparameters Tuning with K-Fold Cross-Validation ----------------------------
# This sections uses K-fold cross validation to select good optimization and model hyperparameters

# K = 3 # Using 3 folds
# d = X_train.shape[1]

# # First trial
# # learning_rates_grid_search  = [1, 0.1, 0.01, 0.001, 0.0001] # Different learning rates to test
# # batch_sizes_grid_search     = [1, 16, 64]                   # Different batch sizes to test
# # epochs_grid_search          = [50, 100, 150, 200]           # Diferent epochs to test
# # lambda_grid_search          = 1e-3            

# # Second trial
# learning_rates_grid_search  = [1, 0.1, 0.01, 0.02, 0.05, 0.001, 0.0001]     # Different learning rates to test
# batch_sizes_grid_search     = [1, 16, 32, 64, 128]                          # Different batch sizes to test
# epochs_grid_search          = [50, 100, 150, 200]                           # Diferent epochs to test
# lambda_grid_search          = 1e-3        

# kf = KFold(n_splits=K, shuffle=True, random_state=2026) # Split 

# def evaluate_model(model : LogisticRegression, X_val : np.ndarray, y_val : np.ndarray):
#     y_pred = model.logistic_function(X_val)         # Predicted outputs
#     accuracy = np.mean((y_pred >= 0.5) == y_val)    # On average, how precise the model is (%)
#     loss = model.BCE_with_L2_regularization(        # Computes the cost w/ L2 Regularization
#         X_val, y_val
#     )

#     return loss, accuracy


# cross_validation_results = []

# for eta in learning_rates_grid_search:
#     for batch_size in batch_sizes_grid_search:
#         for epochs in epochs_grid_search:
#             # For each η, batch_size & epochs:

#             fold_losses = []
#             fold_accuracies = []
            
#             # Generate indices to split data into training and test set.
#             for train_idx, val_idx in kf.split(X_train):
#                 X_training_set, X_validation_set = X_train[train_idx], X_train[val_idx]
#                 y_training_set, y_validation_set = y_train[train_idx], y_train[val_idx]

#                 model = LogisticRegression(d, eta, lambda_=lambda_grid_search)
#                 model.fit(X_training_set, y_training_set, epochs=epochs, batch_size=batch_size)
#                 loss, accuracy = evaluate_model(
#                     model, 
#                     X_validation_set, 
#                     y_validation_set
#                 ) # Returns information about our model (Loss, accuracy)

#                 fold_losses.append(loss)
#                 fold_accuracies.append(accuracy)

#             cross_validation_results.append({
#                 "eta": eta,
#                 "batch_size": batch_size,
#                 "epochs": epochs,
#                 "mean_loss": np.mean(fold_losses),
#                 "std_loss": np.std(fold_losses),
#                 "mean_acc": np.mean(fold_accuracies),
#                 "std_acc": np.std(fold_accuracies)
#             })

# cv_df = pd.DataFrame(cross_validation_results)
# cv_df = cv_df.sort_values("mean_loss") # See which hyper-parameters have the least mean_loss
# print(cv_df)

# best_row = cv_df.iloc[0]
# print(f"Best Configuration:")
# print(best_row)

# cv_df.to_latex("cv_results.tex", index=False, float_format="%.4f")

# ---------------------------- Task 3: Bias–Variance Trade-Off via λ Sweep ---------------------------
# K = 3 # Same setting as before
# d = X_train.shape[1]
# kf = KFold(n_splits=K, shuffle=True, random_state=2026)

# lambdas_bias_var = [0, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1] # The lambdas to test

# def evaluate_model(model : LogisticRegression, X_val : np.ndarray, y_val : np.ndarray):
#     y_pred = model.logistic_function(X_val)         # Predicted outputs
#     accuracy = np.mean((y_pred >= 0.5) == y_val)    # On average, how precise the model is (%)
#     loss = model.BCE_with_L2_regularization(        # Computes the cost w/ L2 Regularization
#         X_val, y_val
#     )

#     return loss, accuracy

# def evaluate_Lambdas(x, y):
#     lambda_results = []
#     for lambda_ in lambdas_bias_var:
#         train_losses = []
#         val_losses = []
#         train_accs = []
#         val_accs = []

#         for train_idx, val_idx in kf.split(x):
#             X_training_set, X_validation_set = x[train_idx], x[val_idx]
#             y_training_set, y_validation_set = y[train_idx], y[val_idx]

#             model = LogisticRegression(d, 0.1, lambda_)
#             model.fit(X_training_set, y_training_set, epochs=200, batch_size=16)

#             # Evaluate bias
#             loss, accuracy = evaluate_model(model, X_training_set, y_training_set)
#             train_losses.append(loss)
#             train_accs.append(accuracy)

#             # Evaluate variance
#             val_loss, val_acc = evaluate_model(model, X_validation_set, y_validation_set)
#             val_losses.append(val_loss)
#             val_accs.append(val_acc)

#         lambda_results.append({
#             "lambda": lambda_,
#             "mean_train_loss": np.mean(train_losses),
#             "mean_val_loss": np.mean(val_losses),
#             "mean_train_acc": np.mean(train_accs),
#             "mean_val_acc": np.mean(val_accs)
#         })
    
#     return lambda_results


# result_1 = evaluate_Lambdas(X_train, y_train)
# lambda_df = pd.DataFrame(result_1)
# print(lambda_df)

# # Plot for loss
# plt.plot(lambda_df["lambda"], lambda_df["mean_train_loss"], marker='o', label="Train loss")
# plt.plot(lambda_df["lambda"], lambda_df["mean_val_loss"], marker='o', label="Validation loss")

# plt.xscale("log")
# plt.xlabel("Lambda")

# plt.ylabel("Cross-Entropy (loss)")
# plt.title("Bias-Variance Trade-Off")
# plt.legend()
# plt.grid(True, which="both", ls="-", alpha=0.5)
# plt.show()

# # Plot for accuracy
# plt.figure()
# plt.plot(lambda_df["lambda"], lambda_df["mean_train_acc"], marker='o', label="Train Accuracy")
# plt.plot(lambda_df["lambda"], lambda_df["mean_val_acc"], marker='o', label="Validation Accuracy")

# plt.xscale("log")
# plt.xlabel("Lambda")
# plt.ylabel("Accuracy")
# plt.title("Accuracy vs. Regularization Strength")
# plt.legend()
# plt.grid(True, which="both", ls="-", alpha=0.5)
# plt.show()

# # Best lambda
# best_lambda = lambda_df.sort_values("mean_val_loss").iloc[0]["lambda"]
# print("Best lambda: ", best_lambda)

# def train_compare(lam):
#    final_model = LogisticRegression(d, 0.1, lambda_=lam)
#    final_model.fit(X_train, y_train, epochs = 200, batch_size = 16)

#    test_loss, test_acc = evaluate_model(final_model, X_test, y_test)

#    print("\nFinal test performance: ")
#    print(f"Test cross-entropy: {test_loss:.3f}")
#    print(f"Test accuracy: {test_acc:.3f}")

#    return test_loss

# print(train_compare(best_lambda) - train_compare(1e-5))

# ----------------- Task 4:  L1-Regularized Logistic Regression and the Regularization Path ----------------------
# # Recall: C = 1 / ƛ
# Cs = np.logspace(-4, 4, 30) # Range of C's to evaluate

# coefs = []
# non_zero_coefs_count =[]

# for C in Cs:
#     # Penalty is deprecated in scikit-learn 1.8+
#     model = SklearnLogisticRegression(
#         l1_ratio=1.0,
#         solver="saga",
#         C=C,
#         max_iter=5000,
#         random_state=2026,
#         warm_start=True # Speed up the fitting
#     )
#     model.fit(X_train, y_train)
#     coefs.append(model.coef_[0]) # Saves the weights
#     non_zero_coefs_count.append(np.sum(model.coef_ != 0)) # Count how many weight parameters are non-zero

# coefs = np.array(coefs)

# # Reg path of coefficients
# K = 57
# top_k = 10
# top_features = np.argsort(np.max(np.abs(coefs), axis=0))[-K:]

# # Print the furthest features
# idx = 9
# print(Cs[idx])
# survivors = np.where(coefs[idx] != 0)[0]
# weights = coefs[idx][survivors]
# print(survivors, weights)

# # Print the worst features
# idx = 20
# print(Cs[idx])
# survivors = np.where(coefs[idx] == 0)[0]
# weights = coefs[idx][survivors]
# print(survivors, weights)

# # Print the useless features
# idx = 12
# print(Cs[idx])
# survivors = np.where(coefs[idx] == 0)[0]
# weights = coefs[idx][survivors]
# print(survivors, weights)

# plt.figure()
# # Each line = one of the top-k features
# # x-axis = C values (inverse regularization strength)
# # y-axis = coefficient value (weight) of that feature
# for i in top_features:
#     transparency = 1.0 - (i / len(top_features))
#     label = ""
#     thickness = 1
#     linestyle = "-"
#     if i < top_k:
#         label = f"Feature {i}"
#         thickness = 2
#     else:
#         label = f"_Feature {i}" # _ Mutes in the legend
#         linestyle = ":"

#     plt.plot(Cs, coefs[:, i], label=label, alpha=transparency ** 4, linewidth=thickness, linestyle=linestyle)

# plt.xscale("log")
# plt.xlabel("C (inverse regularization strength)")
# plt.ylabel("Coefficient value")
# plt.grid(True, which="both", ls="-", alpha=0.5)
# plt.title("L1 Regularization Path")
# plt.legend()
# plt.show()

# # Plot sparsity vs reg
# plt.figure(figsize=(6,4))

# plt.plot(Cs, non_zero_coefs_count, marker="o")

# plt.xscale("log")
# plt.xlabel("C")
# plt.ylabel("Number of non-zero coefficients")
# plt.grid(True, which="both", ls="-", alpha=0.5)
# plt.title("Sparsity vs Regularization Strength")
# plt.show()

# # Cross-Validation performance vs C
# cv_model = LogisticRegressionCV(
#     Cs=Cs,
#     cv=3,
#     l1_ratios=(1,),
#     solver="saga",
#     scoring="accuracy",
#     max_iter=5000,
#     random_state=2026
# )

# cv_model.fit(X_train, y_train)
# mean_cv_scores = cv_model.scores_[1].mean(axis=0)

# plt.figure(figsize=(6,4))
# plt.plot(Cs, mean_cv_scores, marker='o')

# plt.xscale("log")
# plt.xlabel("C")
# plt.ylabel("Mean CV Accuracy")
# plt.grid(True, which="both", ls="-", alpha=0.5)
# plt.title("CV Performance vs C")
# plt.show()

# # Accuracy in function of non-zero weights
# plt.figure()
# plt.plot(non_zero_coefs_count, mean_cv_scores, marker='o', color='green')
# plt.grid(True, which="both", ls="-", alpha=0.5)
# plt.xlabel("Number of Non-zero Features")
# plt.ylabel("Score (Accuracy) of the Model.")
# plt.title("Accuracy vs Non-zero Features")
# plt.show()