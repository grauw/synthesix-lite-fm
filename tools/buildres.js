function main()
{
	console.log("OPLLTone_frequencyTable:");
	console.log(new OPLLToneTable().toAsm());
	console.log("");
	console.log("PSGTone_frequencyTable:");
	console.log(new PSGToneTable().toAsm());
	console.log("");
	console.log("PSGNoise_frequencyTable:");
	console.log(new PSGNoiseTable().toAsm());
	console.log("");
	console.log("PSGEnvelope_frequencyTable:");
	console.log(new PSGEnvelopeTable().toAsm());
}

class OPLLToneTable
{
	constructor()
	{
		this.notes = [];
		for (let i = 0; i < 128; i++)
		{
			this.notes.push(new OPLLTone(Math.pow(2, (i - 69) / 12) * 440));
		}
	}
	
	toAsm()
	{
		return "\tdw " + this.notes.join(", ");
	}
}

class PSGToneTable
{
	constructor()
	{
		this.notes = [];
		for (let i = 0; i < 128; i++)
		{
			this.notes.push(new PSGTone(Math.pow(2, (i - 69) / 12) * 440));
		}
	}
	
	toAsm()
	{
		return "\tdw " + this.notes.join(", ");
	}
}

class PSGNoiseTable
{
	constructor()
	{
		this.notes = [];
		for (let i = 0; i < 128; i++)
		{
			this.notes.push(new PSGNoise(Math.pow(2, (i - 69) / 12 + 6) * 440));
		}
	}
	
	toAsm()
	{
		return "\tdb " + this.notes.join(", ");
	}
}

class PSGEnvelopeTable
{
	constructor()
	{
		this.notes = [];
		for (let i = 0; i < 128; i++)
		{
			this.notes.push(new PSGEnvelope(Math.pow(2, (i - 69) / 12) * 440));
		}
	}
	
	toAsm()
	{
		return "\tdw " + this.notes.join(", ");
	}
}

class OPLLTone
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

class PSGTone
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

class PSGNoise
{
	constructor(frequency)
	{
		this.frequency = frequency;
		this.period = 3579545 / (16 * frequency);
		this.period = Math.min(this.period, 31);
	}

	toString()
	{
		return Math.round(this.period);
	}
}

class PSGEnvelope
{
	constructor(frequency)
	{
		this.frequency = frequency;
		this.period = 3579545 / (256 * frequency);
		this.period = Math.min(this.period, 65535);
	}

	toString()
	{
		return Math.round(this.period);
	}
}

main();
