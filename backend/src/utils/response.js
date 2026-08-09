const success = (res, data = {}, message = 'Success', statusCode = 200) =>
  res.status(statusCode).json({ success: true, message, data, timestamp: new Date().toISOString() });

const created = (res, data = {}, message = 'Created') =>
  success(res, data, message, 201);

const error = (res, message = 'Something went wrong', statusCode = 500, errors = null) =>
  res.status(statusCode).json({
    success: false, message,
    ...(errors && { errors }),
    timestamp: new Date().toISOString(),
  });

const notFound = (res, message = 'Resource not found') => error(res, message, 404);
const unauthorized = (res, message = 'Unauthorized') => error(res, message, 401);
const forbidden = (res, message = 'Forbidden') => error(res, message, 403);
const badRequest = (res, message = 'Bad request', errors = null) => error(res, message, 400, errors);

const paginated = (res, data, meta) =>
  res.status(200).json({ success: true, data, meta, timestamp: new Date().toISOString() });

module.exports = { success, created, error, notFound, unauthorized, forbidden, badRequest, paginated };
