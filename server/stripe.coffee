stripe = require('stripe')('sk_test_5103F9t2l80WEvLLPcQfRPWGFslvo4htyZRCjRQ4YQ8DnRO0Qp18WNWRw7KSOxX9N0f45WU0eYeGXpkAx9MnXkaa700I9qwX0HQ');
Meteor.methods
  stripe: ()=>
    paymentIntent = stripe.paymentIntents.create({
      amount: 1000,
      currency: 'usd',
      payment_method_types: ['card'],
      receipt_email: 'jenny.rosen@example.com',
    });


# stripe = require('stripe')
# # ('sk_test_5103F9t2l80WEvLLPcQfRPWGFslvo4htyZRCjRQ4YQ8DnRO0Qp18WNWRw7KSOxX9N0f45WU0eYeGXpkAx9MnXkaa700I9qwX0HQ');

# YOUR_DOMAIN = 'http://localhost:4242';

# # app.post('/create-checkout-session', async (req, res) => {
# Meteor.methods 
#     stripe: (req, res) =>
#         console.log 'stripe', stripe
#         session = stripe.checkout.sessions.create({
#             line_items: [
#                 {
#                 # // Provide the exact Price ID (for example, pr_1234) of the product you want to sell
#                     price: 'business',
#                     quantity: 1,
#                 },
#             ],
#             mode: 'payment',
#             success_url: "#{YOUR_DOMAIN}/success.html",
#             cancel_url: "#{YOUR_DOMAIN}/cancel.html",
#       })