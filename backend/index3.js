import Web3 from 'web3';
import express from 'express';
import bodyParser from 'body-parser';
import mysql2 from 'mysql2';
import { Alchemy, Network } from "alchemy-sdk";


let web3 = new Web3(new Web3.providers.HttpProvider('https://goerli.infura.io/v3/03afad60d33749f3993c57115f4533ab'));
let obj = web3.eth.accounts.create();
let serverSideError = 500;
let clientSideError = 400;
let success = 200;

const app = express();
const PORT = 5300;

app.use(bodyParser.json());

const con = mysql2.createConnection({
    host: "localhost",
    user : "root",
    password: "abhi2001",
    database : "rider_driver"
});

const config = {
    apiKey: "cyvrDAjFw1w8bOWkL7ZOEYK5QeeQucLY",
    network: Network.ETH_GOERLI,
};
const alchemy = new Alchemy(config);





con.connect(function(err) {
    if (err) throw err;
    console.log("Connected!");
    
  });

  app.get('/',(req,res) => {
    res.send("hello");
  });

  app.post('/createwallet',async (req,res) => {
    const data = req.body;
    let email = data.email;
    let isCreate = "error";
    let name = data.name;
    let mobNo = data.mobNo;
    let isDriver = data.isDriv;
    if(await isWalletCreated(email).then((result) => {
        return result;
    }) === false){
        console.log("account created");
        let obj = await web3.eth.accounts.create();
        let address = obj.address;
        let privateKey = obj.privateKey;
        let pssk = data.pssk;
        isCreate = true;
        let insertDetailsQuery = "Insert into person value( \"" + email + "\",\"" + privateKey + "\",\"" + address + "\",\"" + pssk + "\",\"" + name + "\",\""+ mobNo +"\",\""+isDriver+"\")";
        console.log(insertDetailsQuery);
        con.promise().query(insertDetailsQuery).then(([rows,fields]) => {
            console.log("account created" + rows);
        });
        isCreate = "added"

    }
    else{
        isCreate = "already_added";
        console.log("account not created");
    }

    if(isCreate === "already_added"){
        res.status(201).send("Account already added");
    }
    else{
        res.status(200).send("Account added");
    }
    // res.send( {"message" : isCreate})

  });

  /* ************************ Payments Api ******************************************/


  app.get('/payment',async (req,res) => {
    const data = req.query;
    let senderEmail = data.senderEmail;
    let senderPrivateKey = data.senderPrivateKey;
    let senderAccount = data.senderAccount;
    let receiverAccount = data.receiverAccount;
    let amount = data.amount;
    let isCreate = "error";
    let arrival = data.arrival;
    let dest = data.dest;
    let driverName = data.driverName;
    let riderName = data.riderName;
    if(senderAccount === "wrong_password"){
        isCreate = "wrong_password"
    }
    else{
        if(await isWalletCreated(senderEmail).then((result) => {
            return result;
        }) === true){
            // credential
            try{
                console.log(senderEmail);
                console.log(senderPrivateKey);
                console.log(senderAccount);
                console.log(receiverAccount);
                console.log(amount);
                console.log(arrival);
                console.log(dest);
                console.log(riderName);
                console.log(driverName);



     
                const nonce = await web3.eth.getTransactionCount(senderAccount, 'latest');
                //preparing the transaction
                const transaction = {
                'to': receiverAccount,
                'value': web3.utils.toWei(amount, "ether"),
                'gas': 30000,
                //  'maxFeePerGas': 1000000108,
                'nonce': nonce,
                // optional data field to send message or execute smart contract
                
                };
    
            const signedTx = await web3.eth.accounts.signTransaction(transaction, senderPrivateKey);
    
            //sending the transaction
            let result = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
            console.log(result);
            let hash = String(result["transactionHash"]);
            console.log("debugging seperator")
            console.log(hash);
            let timeStamp = Date.now();
            let date = new Date();
            let url = "https://goerli.etherscan.io/tx/" + hash;
            // let insertRideQuery = "Insert into rides value( \"" + transactionHash + "\",\"" + senderAccount + "\",\"" + receiverAccount + "\",\"" + arrival + "\",\"" + dest + "\")";
            let insertRideQuery = "Insert into rides value(\"" + hash + "\",\"" + senderAccount + "\",\"" + receiverAccount + "\",\"" + arrival + "\",\"" + dest + "\",\""+ amount +"\",\""+ riderName +"\",\""+ driverName +"\",\""+ date +"\",\""+ timeStamp +"\",\""+ url +"\")";
            console.log(insertRideQuery);
            console.log(url);
            con.promise().query(insertRideQuery).then(([rows,fields]) => {
                console.log("ride added!" + rows);
            });
            isCreate = hash;
    
            
            }
            catch(error){
                throw error;
            }
    
        }
        else{
            isCreate = "error_wallet_not_created";
        }

    }

    if(isCreate === "error"){
        res.send({
            hash : isCreate
        });
    }
    else{
            console.log("this is else stat");
            res.send({
                hash : isCreate
            });
          
            
          
        
    }
    // res.send( {"message" : isCreate})

  });

  app.get('/previousPayments',async (req,res)=> {
    console.log("hit");
    const dat = req.query;
    let account = dat.accountNo;
    let getQuery = "Select url as url,timestamp as stamp,date as time,riderName as riderName, driverName as driverName, toAcc as toAcc, arr as arrival, dest as destination, ethCost as cost from rides where fromAcc = \""+ account +"\" ORDER BY stamp ASC";
    let dict = {};
    con.promise().query(getQuery).then(async ([rows,fields]) => {
        // if(rows.length === 0){
        //     return {
        //         "name" : "no_account",
        //         "mobNo": "no_account"
        //     };
        // }

        // console.log(rows);
        // let name= rows[0]['name'];
        // let mobNo = rows[0]['mobNo'];
        // console.log(name + "  " + mobNo);
        // return {
        //     "name" : name,
        //     "mobNo": mobNo
        // }
        console.dir(rows);
        return rows;
    }).then((val) => {
        console.log("val = " + val);

        res.send(
            val
            )
    });
    // const data =  await alchemy.core.getAssetTransfers({
    //     fromAddress: account,
    //     category: ["external", "internal", "erc20", "erc721", "erc1155"],
    //   });
    //   console.log("data" + JSON.stringify(data));

  });

  app.get('/previousPaymentsDriver',async (req,res)=> {
    console.log("hit");
    const dat = req.query;
    let account = dat.accountNo;
    let getQuery = "Select url as url,timestamp as stamp,date as time,riderName as riderName, driverName as driverName, fromAcc as toAcc, arr as arrival, dest as destination, ethCost as cost from rides where toAcc = \""+ account +"\" ORDER BY stamp ASC";
    let dict = {};
    con.promise().query(getQuery).then(async ([rows,fields]) => {
        // if(rows.length === 0){
        //     return {
        //         "name" : "no_account",
        //         "mobNo": "no_account"
        //     };
        // }

        // console.log(rows);
        // let name= rows[0]['name'];
        // let mobNo = rows[0]['mobNo'];
        // console.log(name + "  " + mobNo);
        // return {
        //     "name" : name,
        //     "mobNo": mobNo
        // }
        console.dir(rows);
        return rows;
    }).then((val) => {
        console.log("val = " + val);

        res.send(
            val
            )
    });
    // const data =  await alchemy.core.getAssetTransfers({
    //     fromAddress: account,
    //     category: ["external", "internal", "erc20", "erc721", "erc1155"],
    //   });
    //   console.log("data" + JSON.stringify(data));

  });

  app.get('/driverpayment', async(req,res) => {
    console.log("hit");
    const walletAddress = req.query.accountNo;
    console.log(walletAddress);
    let transactCount = await web3.eth.getTransaction(walletAddress);
    console.log(transactCount);

//     web3.eth.getTransactionCount(walletAddress)
//     .then(count => {
//         for(let i=0; i<count; i++) {
//             web3.eth.getTransactionFromBlock(i, (error, result) => {
//                 if(result && (result.from === walletAddress || result.to === walletAddress)) {
//                     const direction = result.from === walletAddress ? 'outgoing' : 'incoming';
//                     console.log(direction, 'Transaction Details:', result);
//                 }
//             });
//         }
//     })
//     .catch(error => {
//         console.error(error);
//     });
  })

  app.get('/nameMob', async(req,res) =>{
    const data = req.query;
    let email = data.email;
    if(isWalletCreated(email).then((result) => {
        return result;
    })){
        let getQuery = "Select name as name, mobNo as mobNo from person where email_id = \""+ email +"\"";
        console.log(getQuery);
        con.promise().query(getQuery).then(async ([rows,fields]) => {
            if(rows.length === 0){
                return {
                    "name" : "no_account",
                    "mobNo": "no_account"
                };
            }
            console.log(rows);
            let name= rows[0]['name'];
            let mobNo = rows[0]['mobNo'];
            console.log(name + "  " + mobNo);
            return {
                "name" : name,
                "mobNo": mobNo
            }
            
        }).then((val) => {
            console.log("val = " + val);

            res.send(
                {
                    "name" : val["name"],
                    "mobNo": val["mobNo"]
                }
                )
        });

    }
    else{
        res.send(
            {
                "name" : "no_account",
                "mobNo": "no_account"
            }
            )
    }


  })



  app.get('/checkBalance',async (req,res) => {
    const data = req.query;
    let email = data.email;
    let pssk = data.pssk;
    let balance = "";
    if(isWalletCreated(email).then((result) => {
        return result;
    })){
        let balanceQuery = "Select privateKey as pk,account_address as acc from person where email_id = \""+ email + "\" and passKey = \""+ pssk+"\"";
        console.log("account created");
       
        con.promise().query(balanceQuery).then(async ([rows,fields]) => {
            if(rows.length === 0){
                return "wrong_password";
            }
            console.log(rows);
            let acc = rows[0]['acc'];
            console.log("acc = " + acc);
            let res = await makeRequest(acc) + "";
            return res;
            
            
        }).then((val) => {
            console.log("val = " + val);
            res.send({"message" : val})
        });

    }
    else{
        res.send({message: "error"})
    }
    // balance = retBal+"";
  })

  app.get('/getcred',async (req,res) => {
    const data = req.query;
    let email = data.email;
    let pssk = data.pssk;
    let balance = "";
    if(isWalletCreated(email).then((result) => {
        return result;
    })){
        let balanceQuery = "Select privateKey as pk,account_address as acc from person where email_id = \""+ email + "\" and passKey = \""+ pssk+"\"";
       
        con.promise().query(balanceQuery).then(async ([rows,fields]) => {
            if(rows.length === 0){
                return {accountNum : "wrong_password", privateKey : "wrong_password"}
            }
            console.log(rows);
            let acc = rows[0]['acc']+ "";
            let privkey = rows[0]['pk']+ "";
            return {accountNum : acc, privateKey : privkey}
            
            
        }).then((val) => {
            console.log("val = " + val);
            res.send(val)
        });

    }
    else{
        res.send({accountNum : "error", privateKey : "error"});
    }
    // balance = retBal+"";
  })

  app.get('/getcredwithout',async (req,res) => {
    const data = req.query;
    let email = data.email;

    if(isWalletCreated(email).then((result) => {
        return result;
    })){
        let balanceQuery = "Select privateKey as pk,account_address as acc from person where email_id = \""+ email + "\"";
       
        con.promise().query(balanceQuery).then(async ([rows,fields]) => {
            if(rows.length === 0){
                return {accountNum : "wrong_password", privateKey : "wrong_password"}
            }
            console.log(rows);
            let acc = rows[0]['acc']+ "";
            let privkey = rows[0]['pk']+ "";
            return {accountNum : acc, privateKey : privkey}
            
            
        }).then((val) => {
            console.log("val = " + val);
            res.send(val)
        });

    }
    else{
        res.send({accountNum : "error", privateKey : "error"});
    }
    // balance = retBal+"";
  })

  app.get('/isDriver',async (req,res) => {
    let data = req.query;
    let email = data.email;
    
    let balanceQuery = "Select isDriver as isDriver from person where email_id = \""+ email + "\"";
       
        con.promise().query(balanceQuery).then(async ([rows,fields]) => {
            if(rows.length === 0){
                return {isDriver : "0"}
            }
            console.log(rows);
            let isDriv = rows[0]['isDriver']+ "";
            return {isDriver : isDriv};
            
            
        }).then((val) => {
            console.log("val = " + val);
            res.send(val)
        });
  })


  const makeRequest = async (acc) => {
    try {
      const data = JSON.parse(await web3.eth.getBalance(acc))
      console.log(data)
      return data;
    } catch (err) {
      console.log(err)
    }
  }

  function isWalletCreated(email) {
        let myQuery = "Select * from person where email_id = \"" + email + "\"";
        return con.promise().query(myQuery).then(([rows,fields]) => {
            console.log(email + " areareh " + rows);
            if(rows.length === 0){
               
                console.log("empty");
                return false;
                
            }
            else{
                console.log("not empty");
                return true;
                
            }

        })    
  }

  

//  if(isWalletCreated("abhi@gmail.com")){
//     console.log("asgEVGs");
//  }
app.get('/getPrice', async (req,res)=> {
    let distance = parseFloat(req.query.distance);
    
    let usd = await GetUSDExchangeRate();
    let ethRate = await GetETHExchangeRate();
    let totalCost = (distance * 10) * (0.012) * (ethRate);
    let price = (distance/15) * (1.21) * ethRate;
    res.send(
        {
            cost : totalCost.toFixed(5)
        }
    )
})

  app.listen(PORT, () => {
    console.log('SERVER RUNNING AT ${PORT}');
});

export const GetUSDExchangeRate = async () => {
    var requestOptions = { method: "GET", redirect: "follow" };
    return fetch("https://api.coinbase.com/v2/exchange-rates?currency=ETH", requestOptions)
      .then((response) => response.json())
      .then((result) => {return(result.data.rates.USD)})
      .catch((error) => {return("error", error)});
  }
  
  export const GetETHExchangeRate = async () => {
    var requestOptions = { method: "GET", redirect: "follow" };
    return fetch("https://api.coinbase.com/v2/exchange-rates?currency=USD", requestOptions)
      .then((response) => response.json())
      .then((result) => {return(result.data.rates.ETH)})
      .catch((error) => {return("error", error)});
  }



let d = new Date();
console.log(d);

let ethRate = await GetETHExchangeRate();
console.log(ethRate);