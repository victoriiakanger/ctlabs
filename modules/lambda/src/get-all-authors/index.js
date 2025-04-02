const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({
  region: process.env.AWS_REGION,
  apiVersion: "2012-08-10"
});

exports.handler = (event, context, callback) => {
  const params = {
    TableName: process.env.TABLE_AUTHORS
  };
  console.log("TableName:", process.env.TABLE_AUTHORS, typeof process.env.TABLE_AUTHORS);
  dynamodb.scan(params, (err, data) => {
    if (err) {
      console.log(err);
      callback(err);
    } else {
      const authors = data.Items.map(item => {
        return { id: item.id.S, firstName: item.firstName.S, lastName: item.lastName.S };
      });
      callback(null, authors);
    }
  });
};