var SocialW3;
var SocialContractABIObj;
var SchemaMap = {};

function initWeb3NoMetaMask (callback) {
  SocialW3 = new Web3(SocialCardSettings.ethrpc);

  callback();
}

function loadContractABI(callback){
  fetch(SocialCardSettings.socialcardabi)
  .then(response => response.text())
  .then((data) => {
    SocialContractABIObj = new SocialW3.eth.Contract(JSON.parse(data), SocialCardSettings.sociacardcontract);

    callback();
  });
}

function getFieldSchema(callback) {
  // Load up the field schema numbers and field values

  SocialContractABIObj.methods.getSocialInfoSchemaSize().call(async (err, inData) => {
    var schemaSize = parseInt(inData);
    console.log(schemaSize);

    for (i = 1; i < schemaSize + 1; i++) {
      SchemaMap[i] = await SocialContractABIObj.methods.getSocialInfoSchemaAt(i).call();
    }

    callback();
  });
}

async function loadSocialCard(username, callback) {
  var socialCardObj = {};
  var fieldKeys = Object.keys(SchemaMap);
  username = username.toLowerCase();

  // Get MetaData

  var thisSocialCardMetaData = await SocialContractABIObj.methods.getSocialCardMetaData(username).call();

  socialCardObj.createdTime = parseInt(thisSocialCardMetaData[0]);
  socialCardObj.modifiedTime = parseInt(thisSocialCardMetaData[1]);

  socialCardObj.socialCardData = {};

  for (i = 0; i < fieldKeys.length; i++) {
    socialCardObj.socialCardData[fieldKeys[i]] = await SocialContractABIObj.methods.getSocialCardField(username, fieldKeys[i]).call();
  }

  callback(socialCardObj);
}
