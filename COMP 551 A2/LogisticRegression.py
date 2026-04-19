import numpy as np;

class LogisticRegression:
    def __init__(self, d, eta=0.01, lambda_=0.0):
        '''
        Initializes the Logistic Regression model.

        Parameters:
        [NAME]  [TYPE]  [DESCRIPTION]
        d       int     The dimension of the model (# features)
        eta     float   The learning rate
        lambda_ float   The regularization strength (λ * ||w||^2)
        '''
        self.b = 0.0
        self.eta = eta
        self.w = np.zeros(d)    # Initializes a vector of empty weights of dimension d
        self.lambda_ = lambda_

        self.loss_history = []

    def logit(self, X: np.ndarray):
        '''
        Computes the logit from the inputs (for all the entries)
        '''
        return X @ self.w + self.b

    def logistic_function(self, X: np.ndarray) -> np.ndarray:
        '''
        Applies the sigmoid function on the computed logit (for all the entries).
        '''
        return 1 / (1 + np.exp(-self.logit(X)))

    def _binary_cross_entropy(self, X, y_true) -> float:
        '''
        Computes the average cross entropy loss on the entries.
        '''
        eps = 1e-8
        N = len(y_true)

        y_pred = self.logistic_function(X) # Computes the predicted class of each entry in X.
        return -1/N * np.sum(
            # -1/N * ∑ ( (y)*log(y') + (1-y)*log(1-y') )
            y_true * np.log(y_pred + eps) + 
                (1 - y_pred) * np.log(1 - y_pred + eps)
        )

    def BCE_with_L2_regularization(self, X, y_true) -> float:
        '''
        Computes the average cross entropy loss including the regularization penalty.
        Recall convention: λ * ||w||^2
        '''
        loss = self._binary_cross_entropy(X, y_true) + self.lambda_ * np.linalg.norm(self.w) ** 2
        return float(loss)

    def stochastic_gradient_descent(self, X_batch, y_true):
        '''
        Computes the stochastic gradient descent:
        w <- w - η∇J_B(w) (Update weights after computing the average loss on a batch)

        ∇J_B(w) = 1/B * ∑ ( x^n (y' - y) ) + 2λw
        '''
        B = X_batch.shape[0]
        y_pred = self.logistic_function(X_batch) # Compute the predicted outputs 
        
        # Compute the gradient on the batch
        grad_w_of_cost_func = 1/B * X_batch.T @ (y_pred - y_true) + 2 * self.lambda_ * self.w
        grad_b_of_cost_func = 1/B * np.sum(y_pred - y_true) # Do not penalize weight of initial bias

        # Update weights
        self.w -= self.eta * grad_w_of_cost_func
        self.b -= self.eta * grad_b_of_cost_func

    def fit(self, X_train, y_train, epochs, batch_size):
        '''
        Modifies the weights over epochs amount of times on the dataset.

        Parameters:
        X_train = The parameters for each entry
        y_train = The correct binary class output for each entry
        epochs  = Amount of times the fit algorithm will be ran
        batch_size  = Over how many samples the gradient will be computed
        '''
        fit_rng = np.random.default_rng(2026)

        # Iterate epochs amount of times to update the weights
        for _ in range(epochs):
            indices = fit_rng.permutation(len(X_train))
            X_shuffled = X_train[indices]
            y_shuffled = y_train[indices]

            # Go through the entire dataset by batch
            for start in range(0, len(X_train), batch_size):
                end = start + batch_size
                X_batch = X_shuffled[start:end]
                y_batch = y_shuffled[start:end]
                self.stochastic_gradient_descent(X_batch, y_batch) # Update the weights

            # Cache the loss
            loss = self.BCE_with_L2_regularization(X_train, y_train)
            self.loss_history.append(loss)

    def reset(self):
            self.w[:] = 0
            self.b = 0.0
            self.loss_history = []