import Foundation

class MovieQuotes {
    static let shared = MovieQuotes()
    
    private init() {}
    
    let allQuotes: [Question] = [
        Question(
            quote: "There's no place like home.",
            correctAnswer: "The Wizard of Oz",
            wrongAnswers: ["Mary Poppins", "Alice in Wonderland", "Peter Pan"],
            year: 1939,
            difficulty: .easy
        ),
        Question(
            quote: "E.T. phone home.",
            correctAnswer: "E.T. the Extra-Terrestrial",
            wrongAnswers: ["The Iron Giant", "Close Encounters of the Third Kind", "Wall-E"],
            year: 1982,
            difficulty: .easy
        ),
        Question(
            quote: "To infinity and beyond!",
            correctAnswer: "Toy Story",
            wrongAnswers: ["Finding Nemo", "The Incredibles", "Shrek"],
            year: 1995,
            difficulty: .easy
        ),
        Question(
            quote: "Why is the rum gone?",
            correctAnswer: "Pirates of the Caribbean: The Curse of the Black Pearl",
            wrongAnswers: ["Hook", "Treasure Island", "Master and Commander"],
            year: 2003,
            difficulty: .easy
        ),
        Question(
            quote: "I volunteer as tribute!",
            correctAnswer: "The Hunger Games",
            wrongAnswers: ["Divergent", "The Maze Runner", "Ender's Game"],
            year: 2012,
            difficulty: .easy
        ),
        Question(
            quote: "This is Sparta!",
            correctAnswer: "300",
            wrongAnswers: ["Gladiator", "Troy", "Alexander"],
            year: 2006,
            difficulty: .easy
        ),
        Question(
            quote: "Hakuna Matata!",
            correctAnswer: "The Lion King",
            wrongAnswers: ["Madagascar", "Tarzan", "The Jungle Book"],
            year: 1994,
            difficulty: .easy
        ),
        Question(
            quote: "Here's looking at you, kid.",
            correctAnswer: "Casablanca",
            wrongAnswers: ["The Maltese Falcon", "Citizen Kane", "Gone with the Wind"],
            year: 1942,
            difficulty: .easy
        ),
        Question(
            quote: "Roads? Where we're going, we don't need roads.",
            correctAnswer: "Back to the Future",
            wrongAnswers: ["Bill & Ted's Excellent Adventure", "The Time Machine", "Ghostbusters"],
            year: 1985,
            difficulty: .easy
        ),
        Question(
            quote: "I'm just a girl, standing in front of a boy, asking him to love her.",
            correctAnswer: "Notting Hill",
            wrongAnswers: ["Love Actually", "Pretty Woman", "Sleepless in Seattle"],
            year: 1999,
            difficulty: .easy
        ),
        Question(
            quote: "Life is like a box of chocolates.",
            correctAnswer: "Forrest Gump",
            wrongAnswers: ["Big", "Cast Away", "The Truman Show"],
            year: 1994,
            difficulty: .easy
        ),
        Question(
            quote: "Nobody puts Baby in a corner.",
            correctAnswer: "Dirty Dancing",
            wrongAnswers: ["Footloose", "Flashdance", "Grease"],
            year: 1987,
            difficulty: .easy
        ),
        Question(
            quote: "There's no crying in baseball!",
            correctAnswer: "A League of Their Own",
            wrongAnswers: ["The Sandlot", "Moneyball", "Field of Dreams"],
            year: 1992,
            difficulty: .easy
        ),
        Question(
            quote: "You're killing me, Smalls!",
            correctAnswer: "The Sandlot",
            wrongAnswers: ["Little Giants", "The Mighty Ducks", "Angels in the Outfield"],
            year: 1993,
            difficulty: .easy
        ),
        Question(
            quote: "Wax on, wax off.",
            correctAnswer: "The Karate Kid",
            wrongAnswers: ["Kickboxer", "Rocky", "Bloodsport"],
            year: 1984,
            difficulty: .easy
        ),
        Question(
            quote: "Inconceivable!",
            correctAnswer: "The Princess Bride",
            wrongAnswers: ["Willow", "Labyrinth", "Monty Python and the Holy Grail"],
            year: 1987,
            difficulty: .easy
        ),
        Question(
            quote: "I feel the need — the need for speed!",
            correctAnswer: "Top Gun",
            wrongAnswers: ["Days of Thunder", "The Right Stuff", "Pearl Harbor"],
            year: 1986,
            difficulty: .easy
        ),
        Question(
            quote: "Show me the money!",
            correctAnswer: "Jerry Maguire",
            wrongAnswers: ["Wall Street", "Boiler Room", "The Wolf of Wall Street"],
            year: 1996,
            difficulty: .easy
        ),
        Question(
            quote: "Carpe diem. Seize the day.",
            correctAnswer: "Dead Poets Society",
            wrongAnswers: ["Good Will Hunting", "A Beautiful Mind", "Scent of a Woman"],
            year: 1989,
            difficulty: .medium
        ),
        Question(
            quote: "You talking to me?",
            correctAnswer: "Taxi Driver",
            wrongAnswers: ["Serpico", "The French Connection", "Dog Day Afternoon"],
            year: 1976,
            difficulty: .medium
        ),
        Question(
            quote: "I'm walking here! I'm walking here!",
            correctAnswer: "Midnight Cowboy",
            wrongAnswers: ["Taxi Driver", "The Graduate", "Easy Rider"],
            year: 1969,
            difficulty: .medium
        ),
        Question(
            quote: "Rosebud.",
            correctAnswer: "Citizen Kane",
            wrongAnswers: ["The Maltese Falcon", "Casablanca", "Sunset Boulevard"],
            year: 1941,
            difficulty: .medium
        ),
        Question(
            quote: "After all, tomorrow is another day.",
            correctAnswer: "Gone with the Wind",
            wrongAnswers: ["The Wizard of Oz", "Jezebel", "Wuthering Heights"],
            year: 1939,
            difficulty: .medium
        ),
        Question(
            quote: "Fasten your seatbelts. It's going to be a bumpy night.",
            correctAnswer: "All About Eve",
            wrongAnswers: ["Sunset Boulevard", "A Star Is Born", "Some Like It Hot"],
            year: 1950,
            difficulty: .medium
        ),
        Question(
            quote: "I coulda been a contender.",
            correctAnswer: "On the Waterfront",
            wrongAnswers: ["Rocky", "Raging Bull", "A Streetcar Named Desire"],
            year: 1954,
            difficulty: .medium
        ),
        Question(
            quote: "Forget it, Jake. It's Chinatown.",
            correctAnswer: "Chinatown",
            wrongAnswers: ["L.A. Confidential", "The Maltese Falcon", "Double Indemnity"],
            year: 1974,
            difficulty: .medium
        ),
        Question(
            quote: "I am big. It's the pictures that got small.",
            correctAnswer: "Sunset Boulevard",
            wrongAnswers: ["All About Eve", "Singin' in the Rain", "The African Queen"],
            year: 1950,
            difficulty: .medium
        ),
        Question(
            quote: "I see dead people.",
            correctAnswer: "The Sixth Sense",
            wrongAnswers: ["The Others", "Poltergeist", "The Ring"],
            year: 1999,
            difficulty: .easy
        ),
        Question(
            quote: "Houston, we have a problem.",
            correctAnswer: "Apollo 13",
            wrongAnswers: ["The Right Stuff", "Gravity", "Armageddon"],
            year: 1995,
            difficulty: .easy
        ),
        Question(
            quote: "Keep your friends close, but your enemies closer.",
            correctAnswer: "The Godfather Part II",
            wrongAnswers: ["Goodfellas", "Scarface", "Casino"],
            year: 1974,
            difficulty: .medium
        ),
        Question(
            quote: "My precious.",
            correctAnswer: "The Lord of the Rings: The Two Towers",
            wrongAnswers: ["Harry Potter and the Chamber of Secrets", "The Chronicles of Narnia", "Willow"],
            year: 2002,
            difficulty: .easy
        ),
        Question(
            quote: "This is the beginning of a beautiful friendship.",
            correctAnswer: "Casablanca",
            wrongAnswers: ["The Maltese Falcon", "To Have and Have Not", "The Big Sleep"],
            year: 1942,
            difficulty: .medium
        ),
        Question(
            quote: "You can't handle the truth!",
            correctAnswer: "A Few Good Men",
            wrongAnswers: ["The Firm", "Primal Fear", "Philadelphia"],
            year: 1992,
            difficulty: .easy
        ),
        Question(
            quote: "Just when I thought I was out, they pull me back in.",
            correctAnswer: "The Godfather Part III",
            wrongAnswers: ["Goodfellas", "Carlito's Way", "Donnie Brasco"],
            year: 1990,
            difficulty: .medium
        ),
        Question(
            quote: "That'll do, pig. That'll do.",
            correctAnswer: "Babe",
            wrongAnswers: ["Charlotte's Web", "Homeward Bound", "Stuart Little"],
            year: 1995,
            difficulty: .easy
        ),
        Question(
            quote: "You either die a hero, or you live long enough to see yourself become the villain.",
            correctAnswer: "The Dark Knight",
            wrongAnswers: ["Spider-Man", "Iron Man", "X-Men"],
            year: 2008,
            difficulty: .easy
        ),
        Question(
            quote: "Why do we fall, sir? So that we can learn to pick ourselves up.",
            correctAnswer: "Batman Begins",
            wrongAnswers: ["Man of Steel", "Daredevil", "The Green Hornet"],
            year: 2005,
            difficulty: .easy
        ),
        Question(
            quote: "I'm the dude playing the dude, disguised as another dude.",
            correctAnswer: "Tropic Thunder",
            wrongAnswers: ["Pineapple Express", "Superbad", "The Hangover"],
            year: 2008,
            difficulty: .easy
        ),
        Question(
            quote: "It was beauty killed the beast.",
            correctAnswer: "King Kong",
            wrongAnswers: ["Godzilla", "Jurassic Park", "Planet of the Apes"],
            year: 1933,
            difficulty: .medium
        ),
        Question(
            quote: "I wish I knew how to quit you.",
            correctAnswer: "Brokeback Mountain",
            wrongAnswers: ["Milk", "Moonlight", "Call Me by Your Name"],
            year: 2005,
            difficulty: .medium
        ),
        Question(
            quote: "This is the way.",
            correctAnswer: "The Mandalorian",
            wrongAnswers: ["Firefly", "Dune", "Star Trek: Picard"],
            year: 2019,
            difficulty: .easy
        ),
        Question(
            quote: "I'm not bad. I'm just drawn that way.",
            correctAnswer: "Who Framed Roger Rabbit",
            wrongAnswers: ["Space Jam", "Cool World", "The Mask"],
            year: 1988,
            difficulty: .medium
        ),
        Question(
            quote: "It can't rain all the time.",
            correctAnswer: "The Crow",
            wrongAnswers: ["Dark City", "Blade", "Underworld"],
            year: 1994,
            difficulty: .medium
        ),
        Question(
            quote: "I am your father.",
            correctAnswer: "Star Wars: The Empire Strikes Back",
            wrongAnswers: ["Star Trek II: The Wrath of Khan", "Alien", "2001: A Space Odyssey"],
            year: 1980,
            difficulty: .easy
        ),
        Question(
            quote: "It's alive! It's alive!",
            correctAnswer: "Frankenstein",
            wrongAnswers: ["Nosferatu", "Dr. Jekyll and Mr. Hyde", "The Phantom of the Opera"],
            year: 1931,
            difficulty: .medium
        ),
        Question(
            quote: "I'm gonna make him an offer he can't refuse.",
            correctAnswer: "The Godfather",
            wrongAnswers: ["Goodfellas", "Once Upon a Time in America", "Scarface"],
            year: 1972,
            difficulty: .easy
        ),
        Question(
            quote: "You met me at a very strange time in my life.",
            correctAnswer: "Fight Club",
            wrongAnswers: ["Se7en", "American Psycho", "Memento"],
            year: 1999,
            difficulty: .medium
        ),
        Question(
            quote: "Adventure is out there!",
            correctAnswer: "Up",
            wrongAnswers: ["Shrek", "Ice Age", "Madagascar"],
            year: 2009,
            difficulty: .easy
        ),
        Question(
            quote: "I never look back, darling. It distracts from the now.",
            correctAnswer: "The Incredibles",
            wrongAnswers: ["Megamind", "Despicable Me", "Cloudy with a Chance of Meatballs"],
            year: 2004,
            difficulty: .easy
        ),
        Question(
            quote: "To me, you are perfect.",
            correctAnswer: "Love Actually",
            wrongAnswers: ["Notting Hill", "Bridget Jones's Diary", "About Time"],
            year: 2003,
            difficulty: .medium
        ),
        Question(
            quote: "I know kung fu.",
            correctAnswer: "The Matrix",
            wrongAnswers: ["Crouching Tiger, Hidden Dragon", "Kill Bill", "Inception"],
            year: 1999,
            difficulty: .easy
        ),
        Question(
            quote: "Just keep swimming.",
            correctAnswer: "Finding Nemo",
            wrongAnswers: ["Shark Tale", "The Little Mermaid", "SpongeBob SquarePants"],
            year: 2003,
            difficulty: .easy
        ),
        Question(
            quote: "The only way to achieve the impossible is to believe it is possible.",
            correctAnswer: "Alice in Wonderland",
            wrongAnswers: ["Stardust", "Mirror Mirror", "Pan's Labyrinth"],
            year: 2010,
            difficulty: .medium
        ),
        Question(
            quote: "You control your destiny — you don't need magic to do it.",
            correctAnswer: "Brave",
            wrongAnswers: ["How to Train Your Dragon", "Rise of the Guardians", "Epic"],
            year: 2012,
            difficulty: .easy
        ),
        Question(
            quote: "The flower that blooms in adversity is the most rare and beautiful of all.",
            correctAnswer: "Mulan",
            wrongAnswers: ["Kung Fu Panda", "Spirited Away", "Anastasia"],
            year: 1998,
            difficulty: .easy
        ),
        Question(
            quote: "You're braver than you believe, stronger than you seem, and smarter than you think.",
            correctAnswer: "Winnie the Pooh",
            wrongAnswers: ["Paddington", "Peter Rabbit", "Curious George"],
            year: 2011,
            difficulty: .easy
        ),
        Question(
            quote: "Oh yes, the past can hurt. But you can either run from it, or learn from it.",
            correctAnswer: "The Lion King",
            wrongAnswers: ["The Jungle Book", "Bambi", "Land Before Time"],
            year: 1994,
            difficulty: .easy
        ),
        Question(
            quote: "Sometimes the right path is not the easiest one.",
            correctAnswer: "Pocahontas",
            wrongAnswers: ["FernGully", "Spirit: Stallion of the Cimarron", "The Road to El Dorado"],
            year: 1995,
            difficulty: .easy
        ),
        Question(
            quote: "Even miracles take a little time.",
            correctAnswer: "Cinderella",
            wrongAnswers: ["Snow White", "Sleeping Beauty", "The Swan Princess"],
            year: 1950,
            difficulty: .easy
        ),
        Question(
            quote: "A true hero isn't measured by the size of his strength, but by the strength of his heart.",
            correctAnswer: "Hercules",
            wrongAnswers: ["Sinbad: Legend of the Seven Seas", "The Prince of Egypt", "Aladdin"],
            year: 1997,
            difficulty: .easy
        ),
        Question(
            quote: "Some birds aren't meant to be caged.",
            correctAnswer: "The Shawshank Redemption",
            wrongAnswers: ["The Green Mile", "Cool Hand Luke", "Escape from Alcatraz"],
            year: 1994,
            difficulty: .medium
        ),
        Question(
            quote: "Happiness can be found even in the darkest of times, if one only remembers to turn on the light.",
            correctAnswer: "Harry Potter and the Prisoner of Azkaban",
            wrongAnswers: ["The Chronicles of Narnia", "Percy Jackson", "The Golden Compass"],
            year: 2004,
            difficulty: .medium
        ),
        Question(
            quote: "It's the job that's never started as takes longest to finish.",
            correctAnswer: "The Lord of the Rings: The Fellowship of the Ring",
            wrongAnswers: ["Game of Thrones", "Eragon", "The Wheel of Time"],
            year: 2001,
            difficulty: .medium
        ),
        Question(
            quote: "In every job that must be done, there is an element of fun.",
            correctAnswer: "Mary Poppins",
            wrongAnswers: ["The Sound of Music", "Annie", "Chitty Chitty Bang Bang"],
            year: 1964,
            difficulty: .easy
        ),
        Question(
            quote: "Sometimes the smallest things take up the most room in your heart.",
            correctAnswer: "Winnie the Pooh",
            wrongAnswers: ["Paddington", "Stuart Little", "The BFG"],
            year: 2011,
            difficulty: .easy
        ),
        Question(
            quote: "Just because someone stumbles and loses their path doesn't mean they're lost forever.",
            correctAnswer: "X-Men: Days of Future Past",
            wrongAnswers: ["The Avengers", "Justice League", "Watchmen"],
            year: 2014,
            difficulty: .medium
        ),
        Question(
            quote: "Even the smallest person can change the course of the future.",
            correctAnswer: "The Lord of the Rings: The Fellowship of the Ring",
            wrongAnswers: ["Willow", "The NeverEnding Story", "Legend"],
            year: 2001,
            difficulty: .medium
        ),
        Question(
            quote: "Here's Johnny!",
            correctAnswer: "The Shining",
            wrongAnswers: ["Psycho", "Halloween", "Friday the 13th"],
            year: 1980,
            difficulty: .easy
        ),
        Question(
            quote: "You shall not pass!",
            correctAnswer: "The Lord of the Rings: The Fellowship of the Ring",
            wrongAnswers: ["Dungeons & Dragons", "Warcraft", "Excalibur"],
            year: 2001,
            difficulty: .easy
        ),
        Question(
            quote: "I'll be back.",
            correctAnswer: "The Terminator",
            wrongAnswers: ["RoboCop", "Total Recall", "Blade Runner"],
            year: 1984,
            difficulty: .easy
        ),
        Question(
            quote: "Say hello to my little friend!",
            correctAnswer: "Scarface",
            wrongAnswers: ["The Untouchables", "Goodfellas", "Casino"],
            year: 1983,
            difficulty: .easy
        ),
        Question(
            quote: "Get to the chopper!",
            correctAnswer: "Predator",
            wrongAnswers: ["Rambo", "Commando", "Die Hard"],
            year: 1987,
            difficulty: .easy
        ),
        Question(
            quote: "I am serious. And don't call me Shirley.",
            correctAnswer: "Airplane!",
            wrongAnswers: ["The Naked Gun", "Spaceballs", "Caddyshack"],
            year: 1980,
            difficulty: .easy
        ),
        Question(
            quote: "You're tearing me apart, Lisa!",
            correctAnswer: "The Room",
            wrongAnswers: ["Birdemic", "Troll 2", "Sharknado"],
            year: 2003,
            difficulty: .medium
        ),
        Question(
            quote: "Why so serious?",
            correctAnswer: "The Dark Knight",
            wrongAnswers: ["V for Vendetta", "Sin City", "Watchmen"],
            year: 2008,
            difficulty: .easy
        ),
        Question(
            quote: "I coulda had class. I coulda been somebody.",
            correctAnswer: "On the Waterfront",
            wrongAnswers: ["A Streetcar Named Desire", "Rebel Without a Cause", "East of Eden"],
            year: 1954,
            difficulty: .medium
        ),
        Question(
            quote: "Mama says stupid is as stupid does.",
            correctAnswer: "Forrest Gump",
            wrongAnswers: ["Rain Man", "I Am Sam", "Good Will Hunting"],
            year: 1994,
            difficulty: .easy
        ),
        Question(
            quote: "I'll have what she's having.",
            correctAnswer: "When Harry Met Sally",
            wrongAnswers: ["Sleepless in Seattle", "Annie Hall", "Moonstruck"],
            year: 1989,
            difficulty: .medium
        ),
        Question(
            quote: "We're on a mission from God.",
            correctAnswer: "The Blues Brothers",
            wrongAnswers: ["Animal House", "Wayne's World", "Bill & Ted's Excellent Adventure"],
            year: 1980,
            difficulty: .medium
        ),
        Question(
            quote: "I am Iron Man.",
            correctAnswer: "Iron Man",
            wrongAnswers: ["Transformers", "G.I. Joe", "Pacific Rim"],
            year: 2008,
            difficulty: .easy
        ),
        Question(
            quote: "I live my life a quarter mile at a time.",
            correctAnswer: "The Fast and the Furious",
            wrongAnswers: ["Gone in 60 Seconds", "Need for Speed", "Transporter"],
            year: 2001,
            difficulty: .easy
        ),
        Question(
            quote: "The first rule of Fight Club is: You do not talk about Fight Club.",
            correctAnswer: "Fight Club",
            wrongAnswers: ["American Psycho", "Trainspotting", "Snatch"],
            year: 1999,
            difficulty: .easy
        ),
        Question(
            quote: "Wanna know how I got these scars?",
            correctAnswer: "The Dark Knight",
            wrongAnswers: ["The Crow", "Daredevil", "Spawn"],
            year: 2008,
            difficulty: .easy
        ),
        Question(
            quote: "Hasta la vista, baby.",
            correctAnswer: "Terminator 2: Judgment Day",
            wrongAnswers: ["Universal Soldier", "Total Recall", "The Fifth Element"],
            year: 1991,
            difficulty: .easy
        ),
        Question(
            quote: "Go ahead, make my day.",
            correctAnswer: "Sudden Impact",
            wrongAnswers: ["Death Wish", "Bullitt", "The French Connection"],
            year: 1983,
            difficulty: .medium
        ),
        Question(
            quote: "What's in the box?",
            correctAnswer: "Se7en",
            wrongAnswers: ["The Silence of the Lambs", "Prisoners", "Zodiac"],
            year: 1995,
            difficulty: .easy
        ),
        Question(
            quote: "You can't sit with us!",
            correctAnswer: "Mean Girls",
            wrongAnswers: ["Clueless", "Heathers", "Legally Blonde"],
            year: 2004,
            difficulty: .easy
        ),
        Question(
            quote: "That's so fetch!",
            correctAnswer: "Mean Girls",
            wrongAnswers: ["Bring It On", "She's All That", "Freaky Friday"],
            year: 2004,
            difficulty: .easy
        ),
        Question(
            quote: "I'm the captain now.",
            correctAnswer: "Captain Phillips",
            wrongAnswers: ["Zero Dark Thirty", "Lone Survivor", "American Sniper"],
            year: 2013,
            difficulty: .medium
        ),
        Question(
            quote: "You is kind. You is smart. You is important.",
            correctAnswer: "The Help",
            wrongAnswers: ["The Color Purple", "Hidden Figures", "Fences"],
            year: 2011,
            difficulty: .easy
        ),
        Question(
            quote: "What we do in life echoes in eternity.",
            correctAnswer: "Gladiator",
            wrongAnswers: ["Troy", "Alexander", "King Arthur"],
            year: 2000,
            difficulty: .easy
        ),
        Question(
            quote: "Are you not entertained?",
            correctAnswer: "Gladiator",
            wrongAnswers: ["Spartacus", "Ben-Hur", "300"],
            year: 2000,
            difficulty: .easy
        ),
        Question(
            quote: "I drink your milkshake!",
            correctAnswer: "There Will Be Blood",
            wrongAnswers: ["No Country for Old Men", "The Master", "Gangs of New York"],
            year: 2007,
            difficulty: .medium
        ),
        Question(
            quote: "Alright, alright, alright.",
            correctAnswer: "Dazed and Confused",
            wrongAnswers: ["Fast Times at Ridgemont High", "American Graffiti", "Almost Famous"],
            year: 1993,
            difficulty: .medium
        ),
        Question(
            quote: "I'm pretty sure there's a lot more to life than being really, really, ridiculously good looking.",
            correctAnswer: "Zoolander",
            wrongAnswers: ["Dodgeball", "Wedding Crashers", "Tropic Thunder"],
            year: 2001,
            difficulty: .easy
        ),
        Question(
            quote: "I'm in a glass case of emotion!",
            correctAnswer: "Anchorman",
            wrongAnswers: ["Step Brothers", "Old School", "Talladega Nights"],
            year: 2004,
            difficulty: .easy
        ),
        Question(
            quote: "That rug really tied the room together.",
            correctAnswer: "The Big Lebowski",
            wrongAnswers: ["Fargo", "No Country for Old Men", "The Big Sleep"],
            year: 1998,
            difficulty: .medium
        ),
        Question(
            quote: "You're gonna eat lightning and you're gonna crap thunder!",
            correctAnswer: "Rocky",
            wrongAnswers: ["Raging Bull", "The Fighter", "Million Dollar Baby"],
            year: 1976,
            difficulty: .easy
        ),
        Question(
            quote: "Yo, Adrian!",
            correctAnswer: "Rocky",
            wrongAnswers: ["Raging Bull", "Cinderella Man", "The Wrestler"],
            year: 1976,
            difficulty: .easy
        ),
        Question(
            quote: "Life moves pretty fast. If you don't stop and look around once in a while, you could miss it.",
            correctAnswer: "Ferris Bueller's Day Off",
            wrongAnswers: ["The Breakfast Club", "Sixteen Candles", "Risky Business"],
            year: 1986,
            difficulty: .easy
        ),
        Question(
            quote: "I see you.",
            correctAnswer: "Avatar",
            wrongAnswers: ["Dances with Wolves", "John Carter", "Valerian"],
            year: 2009,
            difficulty: .easy
        ),
        Question(
            quote: "I'm the ghost with the most, babe.",
            correctAnswer: "Beetlejuice",
            wrongAnswers: ["Ghostbusters", "The Mask", "Little Shop of Horrors"],
            year: 1988,
            difficulty: .medium
        ),
        Question(
            quote: "As if!",
            correctAnswer: "Clueless",
            wrongAnswers: ["Mean Girls", "Legally Blonde", "10 Things I Hate About You"],
            year: 1995,
            difficulty: .easy
        ),
        Question(
            quote: "Ogres are like onions.",
            correctAnswer: "Shrek",
            wrongAnswers: ["Ice Age", "Monsters, Inc.", "Kung Fu Panda"],
            year: 2001,
            difficulty: .easy
        ),
        Question(
            quote: "What is this? A center for ants?",
            correctAnswer: "Zoolander",
            wrongAnswers: ["Austin Powers", "Dumb and Dumber", "Ace Ventura"],
            year: 2001,
            difficulty: .easy
        ),
        Question(
            quote: "You're my boy, Blue!",
            correctAnswer: "Old School",
            wrongAnswers: ["The Hangover", "Superbad", "Road Trip"],
            year: 2003,
            difficulty: .medium
        ),
        Question(
            quote: "You complete me.",
            correctAnswer: "Jerry Maguire",
            wrongAnswers: ["The Notebook", "Titanic", "Ghost"],
            year: 1996,
            difficulty: .easy
        ),
        Question(
            quote: "Help me, Obi-Wan Kenobi. You're my only hope.",
            correctAnswer: "Star Wars: A New Hope",
            wrongAnswers: ["Flash Gordon", "Battlestar Galactica", "Lost in Space"],
            year: 1977,
            difficulty: .easy
        ),
        Question(
            quote: "Do or do not. There is no try.",
            correctAnswer: "Star Wars: The Empire Strikes Back",
            wrongAnswers: ["The Matrix", "Avatar", "Dune"],
            year: 1980,
            difficulty: .easy
        ),
        Question(
            quote: "It's a trap!",
            correctAnswer: "Star Wars: Return of the Jedi",
            wrongAnswers: ["Independence Day", "Starship Troopers", "Ender's Game"],
            year: 1983,
            difficulty: .easy
        ),
        Question(
            quote: "I have a bad feeling about this.",
            correctAnswer: "Star Wars: A New Hope",
            wrongAnswers: ["Star Trek", "Guardians of the Galaxy", "The Fifth Element"],
            year: 1977,
            difficulty: .easy
        )
    ]
    
    // MARK: - Methods
    
    /// Returns a random selection of questions
    /// - Parameters:
    ///   - count: Number of questions to return
    ///   - difficulty: Optional difficulty filter (.easy, .medium, or .hard)
    /// - Returns: Array of random questions
    func getRandomQuestions(count: Int, difficulty: Question.Difficulty? = nil) -> [Question] {
        var questionsPool = allQuotes
        
        // Filter by difficulty if specified
        if let difficulty = difficulty {
            questionsPool = questionsPool.filter { $0.difficulty == difficulty }
        }
        
        // Shuffle and return the requested number of questions
        return Array(questionsPool.shuffled().prefix(count))
    }
    
    /// Returns questions from a specific year or year range
    func getQuestions(fromYear startYear: Int, toYear endYear: Int? = nil) -> [Question] {
        let endYear = endYear ?? startYear
        return allQuotes.filter { $0.year >= startYear && $0.year <= endYear }
    }
    
    /// Returns all questions of a specific difficulty
    func getQuestions(withDifficulty difficulty: Question.Difficulty) -> [Question] {
        return allQuotes.filter { $0.difficulty == difficulty }
    }
    
    /// Returns all questions of a specific difficulty (alternative method name for compatibility)
    func getQuestionsByDifficulty(_ difficulty: Question.Difficulty) -> [Question] {
        return allQuotes.filter { $0.difficulty == difficulty }
    }
    
    /// Returns a random selection of questions of a specific difficulty with a count
    func getQuestionsByDifficulty(_ difficulty: Question.Difficulty, count: Int) -> [Question] {
        let filtered = allQuotes.filter { $0.difficulty == difficulty }
        return Array(filtered.shuffled().prefix(count))
    }
    
    /// Returns a deterministic selection of questions using a seed (for multiplayer sync)
    func getQuestionsByDifficulty(_ difficulty: Question.Difficulty, count: Int, seed: Int) -> [Question] {
        let filtered = allQuotes.filter { $0.difficulty == difficulty }
        
        // Safety check: If not enough questions, fallback to medium
        guard filtered.count >= count else {
            print("⚠️ Not enough \(difficulty) questions (\(filtered.count)), falling back to medium")
            return getQuestionsByDifficulty(.medium, count: count, seed: seed)
        }
        
        // Use seeded shuffle for deterministic ordering
        var rng = SeededRandomNumberGenerator(seed: seed)
        var shuffled = filtered
        for i in (1..<shuffled.count).reversed() {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffled.swapAt(i, j)
        }
        
        return Array(shuffled.prefix(count))
    }
    
    /// Returns questions by their IDs (for multiplayer sync)
    func getQuestionsByIds(_ ids: [String]) -> [Question] {
        print("🔍 Looking for \(ids.count) questions by ID")
        print("🔍 Sample IDs to find: \(ids.prefix(3))")
        print("🔍 Sample IDs in allQuotes: \(allQuotes.prefix(3).map { $0.id })")
        
        var questions: [Question] = []
        for id in ids {
            if let question = allQuotes.first(where: { $0.id == id }) {
                questions.append(question)
            } else {
                print("❌ Could not find question with ID: \(id)")
            }
        }
        
        print("🔍 Found \(questions.count)/\(ids.count) questions")
        return questions
    }
    
    /// Returns the total number of questions available
    var totalQuestions: Int {
        return allQuotes.count
    }
    
    /// Returns count of questions by difficulty
    func questionCount(forDifficulty difficulty: Question.Difficulty) -> Int {
        return allQuotes.filter { $0.difficulty == difficulty }.count
    }
}

// Seeded random number generator for deterministic shuffling (used in multiplayer)
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: Int) {
        self.state = UInt64(bitPattern: Int64(seed))
    }
    
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
