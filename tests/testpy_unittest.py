import unittest
import testpy
from testpy import StrLen

class TestTestPy(unittest.TestCase):
    def test_get_length(self):
        val = StrLen()
        val.data="hello"
        val.length=3
        self.assertEqual(val.length, 3)
        self.assertEqual(testpy.get_length(val), 5)
        self.assertEqual(val.length, 3)

    def test_update_length(self):
        val = StrLen()
        val.data="goodbye"
        val.length = 1
        self.assertEqual(val.length, 1)
        self.assertEqual(testpy.update_length(val), True)
        self.assertEqual(val.length, 7)

if __name__ == '__main__':
    unittest.main()
