exports.handler = async event => {
  const response = {
    statusCode: 200,
    body: JSON.stringify({
      greeting: `Hello ${event.name}`,
      double: event.number * 2
    }),
  }

  return response
}
