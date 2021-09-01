const fs = require('fs-extra');
const Fasta = require('biojs-io-fasta');
const _ = require('lodash');

const mapDateToCaseNumber = new Map();

/**
 * Opens a FASTA formatted file and reads the DNA sequence from it
 * @param {String} strFilePath 
 * @returns {Promise<Array>} the array of dna sequences found
 */
async function readFastaFile(strFilePath) {
	try {
		if (!fs.existsSync(strFilePath)) {
			console.log("File does not exist.");
			process.exit(1);
		}
		console.log("Opening fasta file " + strFilePath);
		const bufferFileContent = await fs.readFile(strFilePath, 'utf8');
		const strFileContent = bufferFileContent.toString('utf8');
		const arrFastaDataObjects = Fasta.parse(strFileContent);
		arrFastaDataObjects.forEach(objFastaData => {
			objFastaData.seq = _.toUpper(objFastaData.seq);
		});
		return arrFastaDataObjects;
	} catch (err) {
		console.log(err.message)
		process.exit(1);
	}

}

Date.prototype.addDays = function(days) {
    let date = new Date(this.valueOf());
    date.setDate(date.getDate() + days);
    return date;
}

function getDates(startDate, stopDate) {
    let dateArray = new Array();
	startDate = new Date(startDate);
	stopDate = new Date(stopDate);
    let currentDate = startDate;
	
	while (currentDate <= stopDate) {
		day = currentDate.getDate() < 10 ? "0" + currentDate.getDate() : currentDate.getDate();
		month = currentDate.getMonth() < 9 ? "0" + (currentDate.getMonth() + 1) : (currentDate.getMonth() + 1);
		year = currentDate.getFullYear();
        dateArray.push(month + "/" + day + "/" + year);
        currentDate = currentDate.addDays(1);
    }
    return dateArray;
}

async function main() {
    data = await readFastaFile("data.fasta")
	arrDates = []
	data.forEach(sequence => {
		arrDates.push(Object.keys(sequence.ids)[1]);
	});
	arrSortedDates = arrDates.sort((a,b) =>{
		a = Date.parse(a);
		b = Date.parse(b);
		if(a==b){
			return 0
		}
		return (a>b?1:-1)
	})
	
	startDate = arrSortedDates[0];
	endDate = arrSortedDates[arrSortedDates.length-1];
	arrUniqueDates = getDates(startDate, endDate)

	arrUniqueDates.forEach(date => {
		mapDateToCaseNumber.set(date, 0);
	})

	data.forEach(sequence => {
		strDate = Object.keys(sequence.ids)[1]
		mapDateToCaseNumber.set(strDate, mapDateToCaseNumber.get(strDate) + 1)
	})

	let objCases = {};
	objCases["date"] = arrUniqueDates;
	objCases["cases"] = arrUniqueDates.map( date => mapDateToCaseNumber.get(date))
	strData = JSON.stringify(objCases);

	fs.writeFile('data.json', strData, (err) => {
		if (err) {
			throw err;
		}
		console.log("JSON data is saved.");
	});
	
}

main();