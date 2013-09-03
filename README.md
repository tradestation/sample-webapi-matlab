# sample-webapi-matlab

This is a sample MATLAB script that follows the Authorization Code grant type. Here are some key features:

* Automatically open TradeStation login screen in the MATLAB browser
* Listen for authorization code to generate access token
* Make a simple request to the TradeStation WebAPI
* Deserialize data from JSON into MATLAB objects

## Configuration

Modify your Key/Secret/BaseUrl:

    APIKEY = '';
    APISECRET = '';
    BASEURL = 'https://sim.api.tradestation.com/v2/';

Supported BASEURL environments include:

* SIMULATED TRADING - https://sim.api.tradestation.com/v2/
* LIVE TRADING - https://api.tradestation.com/v2/

## How To Run

* Copy tradestationwebapi.m and associated dependencies to your MATLAB Path
* Execute tradestationwebapi in MATLAB

## Contributing & Troubleshooting

If you can make this sample code easier to understand, please fork the repository and send a pull request. We will review the changes and merge as appropriate.

### HTTPS in MATLAB

If you get a message about SSL problems, you will need to add the TradeStation WebAPI SSL certificates to your MATLAB approved certificate store. Take a look at these two resources:

* [Can I force MATLAB to open secure websites with untrusted SSL certificates?](http://www.mathworks.com/support/solutions/en/data/1-3SMHXD/index.html?product=SL&solution=1-3SMHXD)
* [Convert .pem to .crt and .key](http://stackoverflow.com/questions/13732826/convert-pem-to-crt-and-key/14484363#14484363)

If there are any problems, open an issue and we'll take a look! You can also give us feedback by e-mailing webapi@tradestation.com