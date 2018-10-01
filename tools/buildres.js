function main()
{
	console.log("\tALIGN 2");
	console.log("Math_pow2Table:");
	console.log(new Pow2Table().toAsm());
}

function pow2(x)
{
	return Math.pow(2, x);
}

function log2(x)
{
	return Math.log(x) / Math.log(2);
}

class Pow2Table
{
	constructor()
	{
		this.fractions = [];
		for (let i = 0; i < 1024; i++)
		{
			this.fractions.push(Math.floor((pow2(i / 1024) - 1) * 65536));
		}
	}
	
	toAsm()
	{
		return "\tdw " + this.fractions.join(", ");
	}
}

main();
