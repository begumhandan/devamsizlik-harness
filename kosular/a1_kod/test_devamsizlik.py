import unittest

from devamsizlik import devamsizlik_orani, kalan_hak, kaldi_mi


class DevamsizlikTest(unittest.TestCase):
    def test_sinirin_altinda_gecer(self):
        self.assertFalse(kaldi_mi(100, 29))

    def test_tam_sinirda_gecer(self):
        self.assertFalse(kaldi_mi(100, 30))
        self.assertFalse(kaldi_mi(10, 3))  # 0.3 kayan nokta tuzağı

    def test_siniri_asan_kalir(self):
        self.assertTrue(kaldi_mi(100, 31))
        self.assertTrue(kaldi_mi(42, 13))  # %30.95

    def test_hic_devamsizlik_yok(self):
        self.assertFalse(kaldi_mi(14, 0))
        self.assertEqual(devamsizlik_orani(14, 0), 0)

    def test_oran(self):
        self.assertAlmostEqual(devamsizlik_orani(40, 10), 25.0)

    def test_kalan_hak(self):
        self.assertEqual(kalan_hak(42, 10), 2)  # izin: 12
        self.assertEqual(kalan_hak(42, 13), 0)

    def test_gecersiz_girdiler(self):
        for toplam, devamsiz in [(0, 0), (-5, 1), (10, -1), (10, 11)]:
            with self.assertRaises(ValueError):
                kaldi_mi(toplam, devamsiz)


if __name__ == "__main__":
    unittest.main()
