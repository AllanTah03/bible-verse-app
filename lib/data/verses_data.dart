import '../models/verse.dart';

const List<Verse> kPlaceholderVerses = [
  Verse(
    reference: 'Jean 3:16',
    text:
        'Car Dieu a tant aimé le monde qu\'il a donné son Fils unique, afin que quiconque croit en lui ne périsse pas, mais ait la vie éternelle.',
    book: 'Jean',
    testament: 'Nouveau',
    categories: ['Amour', 'Foi', 'Espérance'],
  ),
  Verse(
    reference: 'Psaumes 23:1',
    text: 'Le Seigneur est mon berger, je ne manque de rien.',
    book: 'Psaumes',
    testament: 'Ancien',
    categories: ['Paix', 'Espérance'],
  ),
  Verse(
    reference: 'Philippiens 4:13',
    text: 'Je puis tout en Celui qui me fortifie.',
    book: 'Philippiens',
    testament: 'Nouveau',
    categories: ['Force', 'Encouragement', 'Foi'],
  ),
  Verse(
    reference: 'Josué 1:9',
    text:
        'Ne te l\'ai-je pas commandé ? Fortifie-toi et prends courage ! Ne t\'effraie pas et ne t\'épouvante pas, car l\'Éternel, ton Dieu, est avec toi dans tout ce que tu entreprendras.',
    book: 'Josué',
    testament: 'Ancien',
    categories: ['Encouragement', 'Force'],
  ),
  Verse(
    reference: 'Romains 8:28',
    text:
        'Nous savons du reste que toutes choses concourent au bien de ceux qui aiment Dieu.',
    book: 'Romains',
    testament: 'Nouveau',
    categories: ['Espérance', 'Foi'],
  ),
  Verse(
    reference: 'Isaïe 40:31',
    text:
        'Mais ceux qui espèrent en l\'Éternel renouvellent leurs forces. Ils prennent le vol comme les aigles. Ils courent, et ne se lassent point. Ils marchent, et ne se fatiguent point.',
    book: 'Isaïe',
    testament: 'Ancien',
    categories: ['Force', 'Espérance', 'Encouragement'],
  ),
  Verse(
    reference: 'Matthieu 11:28',
    text:
        'Venez à moi, vous tous qui êtes fatigués et chargés, et je vous donnerai du repos.',
    book: 'Matthieu',
    testament: 'Nouveau',
    categories: ['Paix', 'Encouragement'],
  ),
  Verse(
    reference: 'Proverbes 3:5-6',
    text:
        'Confie-toi en l\'Éternel de tout ton cœur, et ne t\'appuie pas sur ta sagesse ; reconnais-le dans toutes tes voies, et il aplanira tes sentiers.',
    book: 'Proverbes',
    testament: 'Ancien',
    categories: ['Sagesse', 'Foi'],
  ),
  Verse(
    reference: 'Jérémie 29:11',
    text:
        'Car je connais les projets que j\'ai formés sur vous, dit l\'Éternel, projets de paix et non de malheur, afin de vous donner un avenir et de l\'espérance.',
    book: 'Jérémie',
    testament: 'Ancien',
    categories: ['Espérance', 'Encouragement'],
  ),
  Verse(
    reference: 'Galates 5:22-23',
    text:
        'Mais le fruit de l\'Esprit, c\'est l\'amour, la joie, la paix, la patience, la bonté, la bénignité, la fidélité, la douceur, la tempérance.',
    book: 'Galates',
    testament: 'Nouveau',
    categories: ['Amour', 'Paix'],
  ),
  Verse(
    reference: 'Psaumes 46:2',
    text:
        'Dieu est pour nous un refuge et un appui, un secours qui ne manque jamais dans la détresse.',
    book: 'Psaumes',
    testament: 'Ancien',
    categories: ['Force', 'Paix', 'Encouragement'],
  ),
  Verse(
    reference: 'Romains 8:38-39',
    text:
        'Car j\'ai l\'assurance que ni la mort ni la vie, ni les anges ni les dominations, ni le présent ni l\'avenir, ni les puissances, ni la hauteur ni la profondeur, ni aucune autre créature ne pourra nous séparer de l\'amour de Dieu manifesté en Jésus-Christ notre Seigneur.',
    book: 'Romains',
    testament: 'Nouveau',
    categories: ['Amour', 'Espérance', 'Foi'],
  ),
  Verse(
    reference: 'Matthieu 6:33',
    text:
        'Cherchez premièrement le royaume et la justice de Dieu ; et toutes ces choses vous seront données par-dessus.',
    book: 'Matthieu',
    testament: 'Nouveau',
    categories: ['Sagesse', 'Foi'],
  ),
  Verse(
    reference: '1 Corinthiens 13:4-5',
    text:
        'L\'amour est patient, il est plein de bonté ; l\'amour n\'est point envieux ; l\'amour ne se vante point, il ne s\'enfle point d\'orgueil, il ne fait rien de malhonnête.',
    book: '1 Corinthiens',
    testament: 'Nouveau',
    categories: ['Amour'],
  ),
  Verse(
    reference: 'Psaumes 119:105',
    text: 'Ta parole est une lampe à mes pieds, et une lumière sur mon sentier.',
    book: 'Psaumes',
    testament: 'Ancien',
    categories: ['Sagesse', 'Foi'],
  ),
  Verse(
    reference: 'Philippiens 4:6-7',
    text:
        'Ne vous inquiétez de rien ; mais en toutes choses faites connaître vos besoins à Dieu par des prières et des supplications, avec des actions de grâces. Et la paix de Dieu, qui surpasse toute intelligence, gardera vos cœurs et vos pensées en Jésus-Christ.',
    book: 'Philippiens',
    testament: 'Nouveau',
    categories: ['Paix', 'Prière'],
  ),
  Verse(
    reference: 'Ésaïe 41:10',
    text:
        'Ne crains rien, car je suis avec toi ; ne promène pas des regards inquiets, car je suis ton Dieu ; je te fortifie, je viens à ton secours, je te soutiens de ma droite triomphante.',
    book: 'Ésaïe',
    testament: 'Ancien',
    categories: ['Encouragement', 'Force'],
  ),
  Verse(
    reference: 'Jean 14:27',
    text:
        'Je vous laisse la paix, je vous donne ma paix. Je ne vous donne pas comme le monde donne. Que votre cœur ne se trouble point, et ne se laisse point effrayer.',
    book: 'Jean',
    testament: 'Nouveau',
    categories: ['Paix'],
  ),
  Verse(
    reference: 'Hébreux 11:1',
    text:
        'Or la foi est une ferme assurance des choses qu\'on espère, une démonstration de celles qu\'on ne voit pas.',
    book: 'Hébreux',
    testament: 'Nouveau',
    categories: ['Foi', 'Espérance'],
  ),
  Verse(
    reference: 'Psaumes 37:4',
    text:
        'Fais de l\'Éternel tes délices, et il te donnera ce que ton cœur désire.',
    book: 'Psaumes',
    testament: 'Ancien',
    categories: ['Espérance', 'Amour'],
  ),
  Verse(
    reference: '2 Timothée 1:7',
    text:
        'Car ce n\'est pas un esprit de timidité que Dieu nous a donné, mais un esprit de force, d\'amour et de sagesse.',
    book: '2 Timothée',
    testament: 'Nouveau',
    categories: ['Force', 'Amour', 'Sagesse'],
  ),
  Verse(
    reference: 'Jacques 1:5',
    text:
        'Si quelqu\'un d\'entre vous manque de sagesse, qu\'il la demande à Dieu, qui donne à tous libéralement et sans reproche, et elle lui sera donnée.',
    book: 'Jacques',
    testament: 'Nouveau',
    categories: ['Sagesse', 'Prière'],
  ),
  Verse(
    reference: 'Lamentations 3:22-23',
    text:
        'Les bontés de l\'Éternel ne sont pas épuisées, ses compassions ne sont pas à leur terme ; elles se renouvellent chaque matin. Ta fidélité est grande !',
    book: 'Lamentations',
    testament: 'Ancien',
    categories: ['Grâce', 'Espérance', 'Encouragement'],
  ),
  Verse(
    reference: 'Matthieu 5:9',
    text:
        'Heureux ceux qui procurent la paix, car ils seront appelés fils de Dieu !',
    book: 'Matthieu',
    testament: 'Nouveau',
    categories: ['Paix'],
  ),
  Verse(
    reference: 'Psaumes 27:1',
    text:
        'L\'Éternel est ma lumière et mon salut : de qui aurais-je crainte ? L\'Éternel est le soutien de ma vie : de qui aurais-je peur ?',
    book: 'Psaumes',
    testament: 'Ancien',
    categories: ['Force', 'Foi'],
  ),
  Verse(
    reference: 'Apocalypse 21:4',
    text:
        'Il essuiera toute larme de leurs yeux, et la mort ne sera plus, et il n\'y aura plus ni deuil, ni cri, ni douleur, car les premières choses ont disparu.',
    book: 'Apocalypse',
    testament: 'Nouveau',
    categories: ['Espérance', 'Guérison'],
  ),
  Verse(
    reference: 'Deutéronome 31:8',
    text:
        'L\'Éternel marchera lui-même devant toi, il sera lui-même avec toi, il ne te délaissera point et il ne t\'abandonnera point ; ne crains point et ne t\'effraie point.',
    book: 'Deutéronome',
    testament: 'Ancien',
    categories: ['Encouragement', 'Paix'],
  ),
  Verse(
    reference: 'Jean 16:33',
    text:
        'Je vous ai dit ces choses, afin que vous ayez la paix en moi. Vous aurez des tribulations dans le monde ; mais prenez courage, j\'ai vaincu le monde.',
    book: 'Jean',
    testament: 'Nouveau',
    categories: ['Paix', 'Encouragement', 'Force'],
  ),
  Verse(
    reference: '1 Jean 4:8',
    text: 'Celui qui n\'aime pas n\'a pas connu Dieu, car Dieu est amour.',
    book: '1 Jean',
    testament: 'Nouveau',
    categories: ['Amour'],
  ),
  Verse(
    reference: 'Psaumes 34:9',
    text:
        'Goûtez et voyez combien l\'Éternel est bon ! Heureux l\'homme qui cherche en lui son refuge !',
    book: 'Psaumes',
    testament: 'Ancien',
    categories: ['Espérance', 'Grâce'],
  ),
];
