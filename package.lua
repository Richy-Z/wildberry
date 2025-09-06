return {
    name = "Richy-Z/wildberry",
    version = "0.0.1",
    description = "An interpreter for the Little Man Computer (LMC) instruction set.",
    tags = { "LMC", "ISA", "architecture", "CPU", "Von Neumann" },
    license = "Apache 2",
    author = { name = "Richard Ziupsnys", email = "64844585+Richy-Z@users.noreply.github.com" },
    homepage = "https://github.com/Richy-Z/Wildberry",
    files = {
        "**.lua",
        "!test*"
    },

    dependencies = {
        "luvit/fs",
        "Richy-Z/string-extensions",
    }
}
