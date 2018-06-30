class Note
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

let notes = [];
for (let i = 0; i < 128; i++)
{
	notes.push(new Note(Math.pow(2, (i - 69) / 12) * 440));
}

console.log("\tdw " + notes.join(", "));
