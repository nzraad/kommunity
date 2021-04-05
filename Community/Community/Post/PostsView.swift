import UIKit
import CoreLocation

var city = ""

var postClicked = ""

var myPosts : [String] = []
var postsThatIHaveCommentedOn : [String:String] = [:]
var upvotedPosts : [String] = []
var upvotedComments : [String] = []
var downvotedPosts : [String] = []
var downvotedComments : [String] = []

class PostsView: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var values:NSArray = []
    
    var tempUsernameArray : [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! customRowForPosts
        let mainData = values[indexPath.row] as? [String:Any]
        cell.profileID?.text = mainData?["post_id"] as? String
        
        var tempPost = mainData?["post_id"] as? String;
        if(myPosts.contains(tempPost!)){
            cell.profileIcon.image = UIImage(named: "OP")
            cell.profileUsername?.text = "Me"
        }else{
            var tempUsername = adjectives[Int(arc4random_uniform(UInt32(adjectives.count)))] + lastName[Int(arc4random_uniform(UInt32(lastName.count)))]
            while(tempUsernameArray.contains(tempUsername) == true){
                tempUsername = adjectives[Int(arc4random_uniform(UInt32(adjectives.count)))] + lastName[Int(arc4random_uniform(UInt32(lastName.count)))]
            }
            cell.profileIcon.image = UIImage(named: "standing-up-man--\(arc4random_uniform(15)+1)")
            cell.profileUsername?.text = tempUsername
        }
        
        let dateRangeStart = Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        fmt.timeZone = NSTimeZone(name: "UTC") as! TimeZone
        let dateRangeEnd = fmt.date(from:(mainData?["date"] as? String)!)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateRangeEnd!, to: dateRangeStart)
        if(components.month! > 0){
            cell.timeLabel.text = String(components.month!) + " month"
        }else if(components.day! > 0){
            cell.timeLabel.text = String(components.day!) + " d"
            
        }else if(components.hour! > 0){
            cell.timeLabel.text = String(components.hour!) + " h"
            
        }else if(components.minute! > 0){
            cell.timeLabel.text = String(components.minute!) + " m"
        }else{
            cell.timeLabel.text = String(components.second!) + " s"
        }
        
        cell.profileKarma?.text = mainData?["post_rating"] as? String
        cell.profileContent?.text = mainData?["post_content"] as? String
        if(upvotedPosts.contains((mainData?["post_id"] as? String)!) == true){
            cell.upvoteButtonOutlet.setImage(UIImage(named: "upvote_off.png"), for: .disabled)
            cell.downvoteButtonOutlet.isEnabled = true
            cell.upvoteButtonOutlet.isEnabled = false
        }
        if(downvotedPosts.contains((mainData?["post_id"] as? String)!) == true){
            cell.downvoteButtonOutlet.setImage(UIImage(named: "downvote_off.png"), for: .disabled)
            cell.downvoteButtonOutlet.isEnabled = false
            cell.upvoteButtonOutlet.isEnabled = true
        }
        cell.upvoteButtonOutlet.tag = indexPath.row
        cell.downvoteButtonOutlet.tag = indexPath.row
        cell.profileKarma.tag = (mainData!["post_rating"] as AnyObject).integerValue
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! customRowForPosts
        postClicked = cell.profileID!.text!
        let goToEntryView = storyboard?.instantiateViewController(withIdentifier: "CommentView") as! UINavigationController
        present(goToEntryView, animated: true, completion: nil)
    }
    
    func getData() {
        let url = NSURL(string: "http://206.189.174.163/getPosts.php?city=\(city)")
        let data = NSData(contentsOf: url! as URL)
        values = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        posts.reloadData()
    
    }
    
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var posts: UITableView!
    
    @objc func reloadData(_ sender: Any) {
        
        getData()
        refreshControl.endRefreshing()
        posts.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
    
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, e) -> Void in
            if let error = e {
                print("Error:  \(e?.localizedDescription)")
            } else {
                let placemark = placemarks?.last as! CLPlacemark
                
                city = placemark.locality!
                self.getData()
            }
        })
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        
        if(UserDefaults.standard.array(forKey: "upvotedPosts") == nil){
            
        }else{
            upvotedPosts = UserDefaults.standard.array(forKey: "upvotedPosts") as! [String]
        }
        if(UserDefaults.standard.array(forKey: "downvotedPosts") == nil){
            
        }else{
            downvotedPosts = UserDefaults.standard.array(forKey: "downvotedPosts") as! [String]
        }
        if(UserDefaults.standard.array(forKey: "upvotedComments") == nil){
            
        }else{
            upvotedComments = UserDefaults.standard.array(forKey: "upvotedComments") as! [String]
        }
        if(UserDefaults.standard.array(forKey: "downvotedComments") == nil){
            
        }else{
            downvotedComments = UserDefaults.standard.array(forKey: "downvotedComments") as! [String]
        }
        if(UserDefaults.standard.dictionary(forKey: "postsThatIHaveCommentedOn") == nil){
            
        }else{
            postsThatIHaveCommentedOn = UserDefaults.standard.dictionary(forKey: "postsThatIHaveCommentedOn") as! [String : String]
        }
        if(UserDefaults.standard.array(forKey: "myPosts") == nil){
            
        }else{
            myPosts = UserDefaults.standard.array(forKey: "myPosts") as! [String]
        }
        
        self.tabBarController!.tabBar.layer.borderWidth = 0.75
        self.tabBarController!.tabBar.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.3294117647, blue: 0.3529411765, alpha: 1)
        self.tabBarController?.tabBar.clipsToBounds = true
    
        posts.insertSubview(refreshControl, at: 0)
        refreshControl.addTarget(self, action: #selector(reloadData(_:)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.8862745098, green: 0.3294117647, blue: 0.3529411765, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...")

        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    

}

var adjectives = ["Aback","Abaft","Abandoned","Abashed","Aberrant","Abhorrent","Abiding","Abject","Ablaze","Able","Abnormal","Aboriginal","Abortive","Abounding","Abrasive","Abrupt","Absent","Absorbed","Absorbing","Abstracted","Absurd","Abundant","Abusive","Acceptable","Accessible","Accidental","Accurate","Acid","Acidic","Acoustic","Acrid","Adamant","Adaptable","Addicted","Adhesive","Adjoining","Adorable","Adventurous","Afraid","Aggressive","Agonizing","Agreeable","Ahead","Ajar","Alert","Alike","Alive","Alleged","Alluring","Aloof","Amazing","Ambiguous","Ambitious","Amuck","Amused","Amusing","Ancient","Angry","Animated","Annoyed","Annoying","Anxious","Apathetic","Aquatic","Aromatic","Arrogant","Ashamed","Aspiring","Assorted","Astonishing","Attractive","Auspicious","Automatic","Available","Average","Aware","Awesome","Axiomatic","Bad","Barbarous","Bashful","Bawdy","Beautiful","Befitting","Belligerent","Beneficial","Bent","Berserk","Bewildered","Big","Billowy","Bite-sized","Bitter","Bizarre","Black","Black-and-white","Bloody","Blue","Blue-eyed","Blushing","Boiling","Boorish","Bored","Boring","Bouncy","Boundless","Brainy","Brash","Brave","Brawny","Breakable","Breezy","Brief","Bright","Broad","Broken","Brown","Bumpy","Burly","Bustling","Busy","Cagey","Calculating","Callous","Calm","Capable","Capricious","Careful","Careless","Caring","Cautious","Ceaseless","Certain","Changeable","Charming","Cheap","Cheerful","Chemical","Chief","Childlike","Chilly","Chivalrous","Chubby","Chunky","Clammy","Classy","Clean","Clear","Clever","Cloistered","Cloudy","Closed","Clumsy","Cluttered","Coherent","Cold","Colorful","Colossal","Combative","Comfortable","Common","Complete","Complex","Concerned","Condemned","Confused","Conscious","Cooing","Cool","Cooperative","Coordinated","Courageous","Cowardly","Crabby","Craven","Crazy","Creepy","Crooked","Crowded","Cruel","Cuddly","Cultured","Cumbersome","Curious","Curly","Curved","Curvy","Cut","Cute","Cynical","Daffy","Daily","Damaged","Damaging","Damp","Dangerous","Dapper","Dark","Dashing","Dazzling","Dead","Deadpan","Deafening","Dear","Debonair","Decisive","Decorous","Deep","Deeply","Defeated","Defective","Defiant","Delicate","Delicious","Delightful","Demonic","Delirious","Dependent","Depressed","Deranged","Descriptive","Deserted","Detailed","Determined","Devilish","Didactic","Different","Difficult","Diligent","Direful","Dirty","Disagreeable","Disastrous","Discreet","Disgusted","Disgusting","Disillusioned","Dispensable","Distinct","Disturbed","Divergent","Dizzy","Domineering","Doubtful","Drab","Draconian","Dramatic","Dreary","Drunk","Dry","Dull","Dusty","Dynamic","Dysfunctional","Eager","Early","Earsplitting","Earthy","Easy","Eatable","Economic","Educated","Efficacious","Efficient","Elastic","Elated","Elderly","Electric","Elegant","Elfin","Elite","Embarrassed","Eminent","Empty","Enchanted","Enchanting","Encouraging","Endurable","Energetic","Enormous","Entertaining","Enthusiastic","Envious","Equable","Equal","Erect","Erratic","Ethereal","Evanescent","Evasive","Even","Excellent","Excited","Exciting","Exclusive","Exotic","Expensive","Extra-large","Extra-small","Exuberant","Exultant","Fabulous","Faded","Faint","Fair","Faithful","Fallacious","False","Familiar","Famous","Fanatical","Fancy","Fantastic","Far","Far-flung","Fascinated","Fast","Fat","Faulty","Fearful","Fearless","Feeble","Feigned","Female","Fertile","Festive","Few","Fierce","Filthy","Fine","Finicky","First","Fixed","Flagrant","Flaky","Flashy","Flat","Flawless","Flimsy","Flippant","Flowery","Fluffy","Fluttering","Foamy","Foolish","Foregoing","Forgetful","Fortunate","Frail","Fragile","Frantic","Free","Freezing","Frequent","Fresh","Fretful","Friendly","Frightened","Frightening","Full","Fumbling","Functional","Funny","Furry","Furtive","Future","Futuristic","Fuzzy","Gabby","Gainful","Gamy","Gaping","Garrulous","Gaudy","General","Gentle","Giant","Giddy","Gifted","Gigantic","Glamorous","Gleaming","Glib","Glistening","Glorious","Glossy","Godly","Good","Goofy","Gorgeous","Graceful","Grandiose","Grateful","Gratis","Gray","Greasy","Great","Greedy","Green","Grey","Grieving","Groovy","Grotesque","Grouchy","Grubby","Gruesome","Grumpy","Guarded","Guiltless","Gullible","Gusty","Guttural","Habitual","Half","Hallowed","Halting","Handsome","Handy","Hanging","Hapless","Happy","Hard","Hard-to-find","Harmonious","Harsh","Hateful","Heady","Healthy","Heartbreaking","Heavenly","Heavy","Hellish","Helpful","Helpless","Hesitant","Hideous","High","Highfalutin","High-pitched","Hilarious","Hissing","Historical","Holistic","Hollow","Homeless","Homely","Honorable","Horrible","Hospitable","Hot","Huge","Hulking","Humdrum","Humorous","Hungry","Hurried","Hurt","Hushed","Husky","Hypnotic","Hysterical","Icky","Icy","Idiotic","Ignorant","Ill","Illegal","Ill-fated","Ill-informed","Illustrious","Imaginary","Immense","Imminent","Impartial","Imperfect","Impolite","Important","Imported","Impossible","Incandescent","Incompetent","Inconclusive","Industrious","Incredible","Inexpensive","Infamous","Innate","Innocent","Inquisitive","Insidious","Instinctive","Intelligent","Interesting","Internal","Invincible","Irate","Irritating","Itchy","Jaded","Jagged","Jazzy","Jealous","Jittery","Jobless","Jolly","Joyous","Judicious","Juicy","Jumbled","Jumpy","Juvenile","Keen","Kind","Kindhearted","Kindly","Knotty","Knowing","Knowledgeable","Known","Labored","Lackadaisical","Lacking","Lame","Lamentable","Languid","Large","Last","Late","Laughable","Lavish","Lazy","Lean","Learned","Left","Legal","Lethal","Level","Lewd","Light","Like","Likeable","Limping","Literate","Little","Lively","Living","Lonely","Long","Longing","Long-term","Loose","Lopsided","Loud","Loutish","Lovely","Loving","Low","Lowly","Lucky","Ludicrous","Lumpy","Lush","Luxuriant","Lying","Lyrical","Macabre","Macho","Maddening","Madly","Magenta","Magical","Magnificent","Majestic","Makeshift","Male","Malicious","Mammoth","Maniacal","Many","Marked","Massive","Married","Marvelous","Material","Materialistic","Mature","Mean","Measly","Meaty","Medical","Meek","Mellow","Melodic","Melted","Merciful","Mere","Messy","Mighty","Military","Milky","Mindless","Miniature","Minor","Miscreant","Misty","Mixed","Moaning","Modern","Moldy","Momentous","Motionless","Mountainous","Muddled","Mundane","Murky","Mushy","Mute","Mysterious","Naive","Nappy","Narrow","Nasty","Natural","Naughty","Nauseating","Near","Neat","Nebulous","Necessary","Needless","Needy","Neighborly","Nervous","New","Next","Nice","Nifty","Nimble","Nippy","Noiseless","Noisy","Nonchalant","Nondescript","Nonstop","Normal","Nostalgic","Nosy","Noxious","Numberless","Numerous","Nutritious","Nutty","Oafish","Obedient","Obeisant","Obese","Obnoxious","Obscene","Obsequious","Observant","Obsolete","Obtainable","Oceanic","Odd","Offbeat","Old","Old-fashioned","Omniscient","Onerous","Open","Opposite","Optimal","Orange","Ordinary","Organic","Ossified","Outgoing","Outrageous","Outstanding","Oval","Overconfident","Overjoyed","Overrated","Overt","Overwrought","Painful","Painstaking","Pale","Paltry","Panicky","Panoramic","Parallel","Parched","Parsimonious","Past","Pastoral","Pathetic","Peaceful","Penitent","Perfect","Periodic","Permissible","Perpetual","Petite","Phobic","Physical","Picayune","Pink","Piquant","Placid","Plain","Plant","Plastic","Plausible","Pleasant","Plucky","Pointless","Poised","Polite","Political","Poor","Possessive","Possible","Powerful","Precious","Premium","Present","Pretty","Previous","Pricey","Prickly","Private","Probable","Productive","Profuse","Protective","Proud","Psychedelic","Psychotic","Public","Puffy","Pumped","Puny","Purple","Purring","Pushy","Puzzled","Puzzling","Quaint","Quarrelsome","Questionable","Quick","Quiet","Quirky","Quixotic","Quizzical","Rabid","Racial","Ragged","Rainy","Rambunctious","Rampant","Rapid","Rare","Raspy","Ratty","Ready","Real","Rebel","Receptive","Recondite","Red","Redundant","Reflective","Regular","Relieved","Remarkable","Reminiscent","Repulsive","Resolute","Resonant","Responsible","Rhetorical","Rich","Right","Righteous","Rightful","Rigid","Ripe","Ritzy","Roasted","Robust","Romantic","Roomy","Rotten","Rough","Round","Royal","Ruddy","Rude","Rural","Rustic","Ruthless","Sable","Sad","Safe","Salty","Same","Sassy","Satisfying","Savory","Scandalous","Scarce","Scared","Scary","Scattered","Scientific","Scintillating","Scrawny","Screeching","Second","Second-hand","Secret","Secretive","Sedate","Seemly","Selective","Selfish","Separate","Serious","Shaggy","Shaky","Shallow","Sharp","Shiny","Shivering","Shocking","Short","Shrill","Shut","Shy","Sick","Silent","Silky","Silly","Simple","Simplistic","Sincere","Skillful","Skinny","Sleepy","Slim","Slimy","Slippery","Sloppy","Slow","Small","Smart","Smelly","Smiling","Smoggy","Smooth","Sneaky","Snobbish","Snotty","Soft","Soggy","Solid","Somber","Sophisticated","Sordid","Sore","Sour","Sparkling","Special","Spectacular","Spicy","Spiffy","Spiky","Spiritual","Spiteful","Splendid","Spooky","Spotless","Spotted","Spotty","Spurious","Squalid","Square","Squealing","Squeamish","Staking","Stale","Standing","Statuesque","Steadfast","Steady","Steep","Stereotyped","Sticky","Stiff","Stimulating","Stingy","Stormy","Straight","Strange","Striped","Strong","Stupendous","Sturdy","Subdued","Subsequent","Substantial","Successful","Succinct","Sudden","Sulky","Super","Superb","Superficial","Supreme","Swanky","Sweet","Sweltering","Swift","Symptomatic","Synonymous","Taboo","Tacit","Tacky","Talented","Tall","Tame","Tan","Tangible","Tangy","Tart","Tasteful","Tasteless","Tasty","Tawdry","Tearful","Tedious","Teeny","Teeny-tiny","Telling","Temporary","Ten","Tender","Tense","Tenuous","Terrific","Tested","Testy","Thankful","Therapeutic","Thick","Thin","Thinkable","Third","Thirsty","Thoughtful","Thoughtless","Threatening","Thundering","Tidy","Tight","Tightfisted","Tiny","Tired","Tiresome","Toothsome","Torpid","Tough","Towering","Tranquil","Trashy","Tremendous","Tricky","Trite","Troubled","Truculent","True","Truthful","Typical","Ubiquitous","Ultra","Unable","Unaccountable","Unadvised","Unarmed","Unbecoming","Unbiased","Uncovered","Understood","Undesirable","Unequal","Unequaled","Uneven","Unhealthy","Uninterested","Unique","Unkempt","Unknown","Unnatural","Unruly","Unsightly","Unsuitable","Untidy","Unused","Unusual","Unwieldy","Unwritten","Upbeat","Uppity","Upset","Uptight","Used","Useful","Useless","Utopian","Vacuous","Vagabond","Vague","Valuable","Various","Vast","Vengeful","Venomous","Verdant","Versed","Victorious","Vigorous","Violent","Violet","Vivacious","Voiceless","Volatile","Voracious","Vulgar","Wacky","Waggish","Waiting","Wakeful","Wandering","Wanting","Warlike","Warm","Wary","Wasteful","Watery","Weak","Wealthy","Weary","Well-groomed","Well-made","Well-off","Well-to-do","Wet","Whimsical","Whispering","White","Whole","Wholesale","Wicked","Wide","Wide-eyed","Wiggly","Wild","Willing","Windy","Wiry","Wise","Wistful","Witty","Woebegone","Womanly","Wonderful","Wooden","Woozy","Workable","Worried","Worthless","Wrathful","Wretched","Wrong","Wry","Yellow","Yielding","Young","Youthful","Yummy","Zany","Zealous","Zesty","Zippy","Zonked"];

var lastName = ["Abbott","Acevedo","Acosta","Adams","Adkins","Aguilar","Aguirre","Albert","Alexander","Alford","Allen","Allison","Alston","Alvarado","Alvarez","Anderson","Andrews","Anthony","Armstrong","Arnold","Ashley","Atkins","Atkinson","Austin","Avery","Avila","Ayala","Ayers","Bailey","Baird","Baker","Baldwin","Ball","Ballard","Banks","Barber","Barker","Barlow","Barnes","Barnett","Barr","Barrera","Barrett","Barron","Barry","Bartlett","Barton","Bass","Bates","Battle","Bauer","Baxter","Beach","Bean","Beard","Beasley","Beck","Becker","Bell","Bender","Benjamin","Bennett","Benson","Bentley","Benton","Berg","Berger","Bernard","Berry","Best","Bird","Bishop","Black","Blackburn","Blackwell","Blair","Blake","Blanchard","Blankenship","Blevins","Bolton","Bond","Bonner","Booker","Boone","Booth","Bowen","Bowers","Bowman","Boyd","Boyer","Boyle","Bradford","Bradley","Bradshaw","Brady","Branch","Bray","Brennan","Brewer","Bridges","Briggs","Bright","Britt","Brock","Brooks","Brown","Browning","Bruce","Bryan","Bryant","Buchanan","Buck","Buckley","Buckner","Bullock","Burch","Burgess","Burke","Burks","Burnett","Burns","Burris","Burt","Burton","Bush","Butler","Byers","Byrd","Cabrera","Cain","Calderon","Caldwell","Calhoun","Callahan","Camacho","Cameron","Campbell","Campos","Cannon","Cantrell","Cantu","Cardenas","Carey","Carlson","Carney","Carpenter","Carr","Carrillo","Carroll","Carson","Carter","Carver","Case","Casey","Cash","Castaneda","Castillo","Castro","Cervantes","Chambers","Chan","Chandler","Chaney","Chang","Chapman","Charles","Chase","Chavez","Chen","Cherry","Christensen","Christian","Church","Clark","Clarke","Clay","Clayton","Clements","Clemons","Cleveland","Cline","Cobb","Cochran","Coffey","Cohen","Cole","Coleman","Collier","Collins","Colon","Combs","Compton","Conley","Conner","Conrad","Contreras","Conway","Cook","Cooke","Cooley","Cooper","Copeland","Cortez","Cote","Cotton","Cox","Craft","Craig","Crane","Crawford","Crosby","Cross","Cruz","Cummings","Cunningham","Curry","Curtis","Dale","Dalton","Daniel","Daniels","Daugherty","Davenport","David","Davidson","Davis","Dawson","Day","Dean","Decker","Dejesus","Delacruz","Delaney","Deleon","Delgado","Dennis","Diaz","Dickerson","Dickson","Dillard","Dillon","Dixon","Dodson","Dominguez","Donaldson","Donovan","Dorsey","Dotson","Douglas","Downs","Doyle","Drake","Dudley","Duffy","Duke","Duncan","Dunlap","Dunn","Duran","Durham","Dyer","Eaton","Edwards","Elliott","Ellis","Ellison","Emerson","England","English","Erickson","Espinoza","Estes","Estrada","Evans","Everett","Ewing","Farley","Farmer","Farrell","Faulkner","Ferguson","Fernandez","Ferrell","Fields","Figueroa","Finch","Finley","Fischer","Fisher","Fitzgerald","Fitzpatrick","Fleming","Fletcher","Flores","Flowers","Floyd","Flynn","Foley","Forbes","Ford","Foreman","Foster","Fowler","Fox","Francis","Franco","Frank","Franklin","Franks","Frazier","Frederick","Freeman","French","Frost","Fry","Frye","Fuentes","Fuller","Fulton","Gaines","Gallagher","Gallegos","Galloway","Gamble","Garcia","Gardner","Garner","Garrett","Garrison","Garza","Gates","Gay","Gentry","George","Gibbs","Gibson","Gilbert","Giles","Gill","Gillespie","Gilliam","Gilmore","Glass","Glenn","Glover","Goff","Golden","Gomez","Gonzales","Gonzalez","Good","Goodman","Goodwin","Gordon","Gould","Graham","Grant","Graves","Gray","Green","Greene","Greer","Gregory","Griffin","Griffith","Grimes","Gross","Guerra","Guerrero","Guthrie","Gutierrez","Guy","Guzman","Hahn","Hale","Haley","Hall","Hamilton","Hammond","Hampton","Hancock","Haney","Hansen","Hanson","Hardin","Harding","Hardy","Harmon","Harper","Harrell","Harrington","Harris","Harrison","Hart","Hartman","Harvey","Hatfield","Hawkins","Hayden","Hayes","Haynes","Hays","Head","Heath","Hebert","Henderson","Hendricks","Hendrix","Henry","Hensley","Henson","Herman","Hernandez","Herrera","Herring","Hess","Hester","Hewitt","Hickman","Hicks","Higgins","Hill","Hines","Hinton","Hobbs","Hodge","Hodges","Hoffman","Hogan","Holcomb","Holden","Holder","Holland","Holloway","Holman","Holmes","Holt","Hood","Hooper","Hoover","Hopkins","Hopper","Horn","Horne","Horton","House","Houston","Howard","Howe","Howell","Hubbard","Huber","Hudson","Huff","Huffman","Hughes","Hull","Humphrey","Hunt","Hunter","Hurley","Hurst","Hutchinson","Hyde","Ingram","Irwin","Jackson","Jacobs","Jacobson","James","Jarvis","Jefferson","Jenkins","Jennings","Jensen","Jimenez","Johns","Johnson","Johnston","Jones","Jordan","Joseph","Joyce","Joyner","Juarez","Justice","Kane","Kaufman","Keith","Keller","Kelley","Kelly","Kemp","Kennedy","Kent","Kerr","Key","Kidd","Kim","King","Kinney","Kirby","Kirk","Kirkland","Klein","Kline","Knapp","Knight","Knowles","Knox","Koch","Kramer","Lamb","Lambert","Lancaster","Landry","Lane","Lang","Langley","Lara","Larsen","Larson","Lawrence","Lawson","Le","Leach","Leblanc","Lee","Leon","Leonard","Lester","Levine","Levy","Lewis","Lindsay","Lindsey","Little","Livingston","Lloyd","Logan","Long","Lopez","Lott","Love","Lowe","Lowery","Lucas","Luna","Lynch","Lynn","Lyons","Macdonald","Macias","Mack","Madden","Maddox","Maldonado","Malone","Mann","Manning","Marks","Marquez","Marsh","Marshall","Martin","Martinez","Mason","Massey","Mathews","Mathis","Matthews","Maxwell","May","Mayer","Maynard","Mayo","Mays","Mcbride","Mccall","Mccarthy","Mccarty","Mcclain","Mcclure","Mcconnell","Mccormick","Mccoy","Mccray","Mccullough","Mcdaniel","Mcdonald","Mcdowell","Mcfadden","Mcfarland","Mcgee","Mcgowan","Mcguire","Mcintosh","Mcintyre","Mckay","Mckee","Mckenzie","Mckinney","Mcknight","Mclaughlin","Mclean","Mcleod","Mcmahon","Mcmillan","Mcneil","Mcpherson","Meadows","Medina","Mejia","Melendez","Melton","Mendez","Mendoza","Mercado","Mercer","Merrill","Merritt","Meyer","Meyers","Michael","Middleton","Miles","Miller","Mills","Miranda","Mitchell","Molina","Monroe","Montgomery","Montoya","Moody","Moon","Mooney","Moore","Morales","Moran","Moreno","Morgan","Morin","Morris","Morrison","Morrow","Morse","Morton","Moses","Mosley","Moss","Mueller","Mullen","Mullins","Munoz","Murphy","Murray","Myers","Nash","Navarro","Neal","Nelson","Newman","Newton","Nguyen","Nichols","Nicholson","Nielsen","Nieves","Nixon","Noble","Noel","Nolan","Norman","Norris","Norton","Nunez","Obrien","Ochoa","Oconnor","Odom","Odonnell","Oliver","Olsen","Olson","Oneal","Oneil","Oneill","Orr","Ortega","Ortiz","Osborn","Osborne","Owen","Owens","Pace","Pacheco","Padilla","Page","Palmer","Park","Parker","Parks","Parrish","Parsons","Pate","Patel","Patrick","Patterson","Patton","Paul","Payne","Pearson","Peck","Pena","Pennington","Perez","Perkins","Perry","Peters","Petersen","Peterson","Petty","Phelps","Phillips","Pickett","Pierce","Pittman","Pitts","Pollard","Poole","Pope","Porter","Potter","Potts","Powell","Powers","Pratt","Preston","Price","Prince","Pruitt","Puckett","Pugh","Quinn","Ramirez","Ramos","Ramsey","Randall","Randolph","Rasmussen","Ratliff","Ray","Raymond","Reed","Reese","Reeves","Reid","Reilly","Reyes","Reynolds","Rhodes","Rice","Rich","Richard","Richards","Richardson","Richmond","Riddle","Riggs","Riley","Rios","Rivas","Rivera","Rivers","Roach","Robbins","Roberson","Roberts","Robertson","Robinson","Robles","Rocha","Rodgers","Rodriguez","Rodriquez","Rogers","Rojas","Rollins","Roman","Romero","Rosa","Rosales","Rosario","Rose","Ross","Roth","Rowe","Rowland","Roy","Ruiz","Rush","Russell","Russo","Rutledge","Ryan","Salas","Salazar","Salinas","Sampson","Sanchez","Sanders","Sandoval","Sanford","Santana","Santiago","Santos","Sargent","Saunders","Savage","Sawyer","Schmidt","Schneider","Schroeder","Schultz","Schwartz","Scott","Sears","Sellers","Serrano","Sexton","Shaffer","Shannon","Sharp","Sharpe","Shaw","Shelton","Shepard","Shepherd","Sheppard","Sherman","Shields","Short","Silva","Simmons","Simon","Simpson","Sims","Singleton","Skinner","Slater","Sloan","Small","Smith","Snider","Snow","Snyder","Solis","Solomon","Sosa","Soto","Sparks","Spears","Spence","Spencer","Stafford","Stanley","Stanton","Stark","Steele","Stein","Stephens","Stephenson","Stevens","Stevenson","Stewart","Stokes","Stone","Stout","Strickland","Strong","Stuart","Suarez","Sullivan","Summers","Sutton","Swanson","Sweeney","Sweet","Sykes","Talley","Tanner","Tate","Taylor","Terrell","Terry","Thomas","Thompson","Thornton","Tillman","Todd","Torres","Townsend","Tran","Travis","Trevino","Trujillo","Tucker","Turner","Tyler","Tyson","Underwood","Valdez","Valencia","Valentine","Valenzuela","Vance","Vang","Vargas","Vasquez","Vaughan","Vaughn","Vazquez","Vega","Velasquez","Velazquez","Velez","Villarreal","Vincent","Vinson","Wade","Wagner","Walker","Wall","Wallace","Waller","Walls","Walsh","Walter","Walters","Walton","Ward","Ware","Warner","Warren","Washington","Waters","Watkins","Watson","Watts","Weaver","Webb","Weber","Webster","Weeks","Weiss","Welch","Wells","West","Wheeler","Whitaker","White","Whitehead","Whitfield","Whitley","Whitney","Wiggins","Wilcox","Wilder","Wiley","Wilkerson","Wilkins","Wilkinson","William","Williams","Williamson","Willis","Wilson","Winters","Wise","Witt","Wolf","Wolfe","Wong","Wood","Woodard","Woods","Woodward","Wooten","Workman","Wright","Wyatt","Wynn","Yang","Yates","York","Young","Zamora","Zimmerman"];
