# imports section
from subprocess import check_output
from pyspark.sql import SparkSession
from pyspark.sql.functions import (count, col)
from pyspark.ml import Pipeline
from pyspark.ml.feature import (OneHotEncoder, 
                                StringIndexer, 
                                VectorAssembler)
from pyspark.ml.classification import (LogisticRegression, 
                                       DecisionTreeClassifier, 
                                       RandomForestClassifier)
from pyspark.ml.evaluation import BinaryClassificationEvaluator


spark = SparkSession.builder.appName('MLexample').getOrCreate()
train = spark.read.format("csv").option("header", True).option("separator", ",").load("hdfs://namenode:9000/train.csv")
test = spark.read.format("csv").option("header", True).option("separator", ",").load("hdfs://namenode:9000/test.csv")

train.printSchema()
train.toPandas().head(15)
# numerical variabels
num_vars = ["Age", "Sibsp", "Parch", "Fare"]

# categorical variables
cat_vars = ["Survived", "Pclass", "Sex", "Embarked"]

# count null values in columns
def countNull(df, var):
    return df.where(df[var].isNull()).count()

all_cols = num_vars + cat_vars
{var: countNull(train, var) for var in all_cols}

train = train.select(
    col("Age").cast("float"),
    col("Sibsp").cast("float"),
    col("Parch").cast("float"),
    col("Fare").cast("double"),
    col("Survived").cast("float"),
    col("Pclass").cast("float"),
    col("Sex"),
    col("Embarked")
)

# impute missing "Age" values with average
age_mean = train.groupBy().mean("Age").first()[0]

# impute missing "Embarked" with mode
embarked_mode = train.groupBy("Embarked").count().collect()[-1][0]

# fill-in missing values
train = train.fillna({
    "Age": age_mean,
    "Embarked": embarked_mode
})

train.show(5)

# featurize categorical columns
stages = []
for cat_var in cat_vars:
    # Category Indexing with StringIndexer
    stringIndexer = StringIndexer(
        inputCol=cat_var,
        outputCol=cat_var+"_indx")
    # Use OneHotEncoder to convert categorical variables into binary SparseVectors
    encoder = OneHotEncoder(
        inputCols=[stringIndexer.getOutputCol()],
        outputCols=[cat_var + "_vec"])
    # Add stages.  These are not run here, but will run all at once later on.
    stages += [stringIndexer, encoder]


# Convert label into label indices using the StringIndexer
label_indx = StringIndexer(
    inputCol="Survived", 
    outputCol="label")
stages += [label_indx]


assembler_inputs = [c+"_vec" for c in cat_vars] + num_vars
assembler = VectorAssembler(
    inputCols=assembler_inputs,
    outputCol="features")
stages += [assembler]

# Create a Pipeline.
pipeline = Pipeline(stages=stages)

# Run the feature transformations.
#  - fit() computes feature statistics as needed.
#  - transform() actually transforms the features.
train = pipeline.fit(train).transform(train)
# Keep relevant columns
selectedcols = ["label", "features"]
train = train.select(selectedcols)
train.show(5)


(train1, test1) = train.randomSplit([0.8, 0.2], seed=777)
print(train1.count())
print(test1.count())


# 1. Logistic regression model
logr = LogisticRegression(
    maxIter = 3,
    regParam = 0.05,
    labelCol="label"
)

# 2. decision tree model
'''
d_tree = DecisionTreeClassifier(
    maxDepth = 3,
    labelCol = "label"
)

# 3. random forest model
r_forest = RandomForestClassifier(
    numTrees = 3,
    labelCol = "label"
)
'''
# fit models
lr_model = logr.fit(train1)
#dt_model = d_tree.fit(train1)
#rf_model = r_forest.fit(train1)


# model evaluator
def testModel(model, df):
    pred = model.transform(df)
    evaluator = BinaryClassificationEvaluator(labelCol="label")
    return evaluator.evaluate(pred)

# accuracy output
'''models = {
    "Logistic regression": lr_model,
    "Decision tree": dt_model,
    "Random forest": rf_model
}

# model performance comparisson
{model_name: testModel(model, test1) for model_name,model in models.items()}
'''
print("************ACCURACY RESULT********************");
result = testModel(lr_model, test1)
print("Accuracy of Logistic Regression:" + str(result));
print("************END********************");
