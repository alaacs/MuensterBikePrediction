require(randomForest)
require(rattle)

## -------------- Load Data --------------------
# Load preprocessed data
data = 

# Create training and test set
indices = sample(nrow(data), nrow(data)*0.7, replace = FALSE)
train = data[indices,]
test = data[-indices,]

## ----------- Define Functions ----------------
# Define RMSE function
rmse = function(predicted, observed) {
  sqrt(mean((predicted - observed)^2))
}

# Define parameter testing function
f = function(a, b) {
  model = randomForest(
    x = train[,-1],
    y = train[,1],
    ntree = a,
    nodesize = b
  )
  
  prediction = predict(model, test[,-1])
  
  rmse(prediction, test[,1])
}

## ------------- Test Parameters ---------------
# Define values to be tested
values_ntree = c(10,20,40,60,80,100,150,200,250,300,400,500,750,1000)
values_nodesize = c(1,2,3,5,10,15,20,30,40,50,60,70,80,90,100)

# Create one data frame with all possible combinations of those values
values = data.frame(
  ntree = rep(values_ntree, each = length(values_nodesize)),
  nodesize = rep(values_nodesize, times = length(values_ntree))
)

# Test for all different combinations of ntree and nodesize
errors = mapply(FUN = f, values[,1], values[,2])
optimal = values[which(errors == min(errors))[1],]

## --------------- Final model ------------------
model = randomForest(
  x = train[,-1],
  y = train[,1],
  ntree = optimal[[1]],
  nodesize = optimal[[2]]
)

prediction = predict(model, test[,-1])

rmse(prediction, test[,1])