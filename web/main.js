let memory = []

const tableBody = document.querySelector("#memoryTable tbody");
const cellTemplate = document.querySelector("#memoryCell");

for (let row = 0; row < 10; row++) {
    const tr = document.createElement("tr");

    for (let col = 0; col < 10; col++) {
        const addr = row * 10 + col;
        const td = cellTemplate.content.cloneNode(true);

        td.querySelector(".addr").textContent = addr.toString().padStart(2, "0");

        const val = td.querySelector(".val");
        val.textContent = "000";

        tr.appendChild(td);

        memory.push(val);
    }

    tableBody.appendChild(tr);
}

memory.forEach((t) => console.log(t.textContent));