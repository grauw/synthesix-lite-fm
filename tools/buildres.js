function main()
{
	console.log("OPLLNote_frequencyTable:");
	console.log(new OPLLNoteTable().toAsm());
	console.log("");
	console.log("PSGNote_frequencyTable:");
	console.log(new PSGNoteTable().toAsm());
}

class OPLLNoteTable
{
	constructor()
	{
		this.notes = [];
		for (let i = 0; i < 128; i++)
		{
			this.notes.push(new OPLLNote(Math.pow(2, (i - 69) / 12) * 440));
		}
	}
	
	toAsm()
	{
		return "\tdw " + this.notes.join(", ");
	}
}

class PSGNoteTable
{
	constructor()
	{
		this.notes = [];
		for (let i = 0; i < 128; i++)
		{
			this.notes.push(new PSGNote(Math.pow(2, (i - 69) / 12) * 440));
		}
	}
	
	toAsm()
	{
		return "\tdw " + this.notes.join(", ");
	}
}

class OPLLNote
{
	constructor(frequency)
	{
		this.frequency = frequency;
		this.fnum = frequency * Math.pow(2, 18) / (3579545 / 72);
		this.oct = 0;
		while (this.fnum >= 511.5 && this.oct < 7)
		{
			this.fnum /= 2;
			this.oct++;
		}
		this.fnum = Math.min(this.fnum, 511);
	}

	toString()
	{
		return this.oct << 9 | Math.round(this.fnum);
	}
}

class PSGNote
{
	constructor(frequency)
	{
		this.frequency = frequency;
		this.period = 3579545 / (16 * frequency);
		this.period = Math.min(this.period, 4095);
	}

	toString()
	{
		return Math.round(this.period);
	}
}

main();
