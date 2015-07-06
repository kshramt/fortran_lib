#!/usr/bin/python


import unittest
import sys
import json
import io


def main(argv):
    parse_argv(argv)
    json.dump(parse_etas_solve(sys.stdin), sys.stdout)


def parse_etas_solve(fp):
    version = parse_version(fp)
    ret = {}
    ret['version'] = version
    if version == 6:
        parse_etas_solve_6(fp, ret)
    else:
        raise NotImplementedError(version)
    return ret


def parse_etas_solve_6(fp, ret):

    ret['log'] = []
    ret['by_log'] = {}
    for l in fp:
        if l.startswith(' LOG:'):
            ret['log'].append(parse_log_6(l))
        elif l.startswith('iterations'):
            ret['iterations'] = int(fp.readline())
        elif l.startswith('iter_best'):
            ret['iter_best'] = int(fp.readline())
        elif l.startswith('best log-likelihood'):
            ret['log_likelihood'] = float(fp.readline())
        elif l.startswith('by_log: c, p, α, K, μ'):
            ret['by_log']['solution'] = list(map(float, fp.readline().split()))
        elif l.startswith('by_log: Jacobian'):
            ret['by_log']['jacobian'] = list(map(float, fp.readline().split()))
        elif l.startswith('by_log: Hessian'):
            ret['by_log']['hessian'] = parse_hessian(fp, 5)
        elif l.startswith('c, p, α, K, μ'):
            ret['solution'] = list(map(float, fp.readline().split()))
        elif l.startswith('Jacobian'):
            ret['jacobian'] = list(map(float, fp.readline().split()))
        elif l.startswith('Hessian'):
            ret['hessian'] = parse_hessian(fp, 5)
        elif l.startswith('converge_by_gradient, converge_by_step_size, converge_at_corner'):
            (
                ret['converge_by_gradient'],
                ret['converge_by_step_size'],
                ret['converge_at_corner'],
            ) = list(map(parse_logical, fp.readline().split()))
        elif l.startswith('fixed'):
            ret['fixed'] = list(map(parse_logical, fp.readline().split()))
        elif l.startswith('on_lower'):
            ret['on_lower'] = list(map(parse_logical, fp.readline().split()))
        elif l.startswith('on_upper'):
            ret['on_upper'] = list(map(parse_logical, fp.readline().split()))


def parse_hessian(fp, n):
    ret = []
    for i in range(n):
        ret.append(list(map(float, fp.readline().split())))
    return ret


def parse_log_6(l):
    (
        log,
        step,
        is_convex,
        is_within,
        is_line_search,
        negative_log_likelihood,
        c,
        p,
        alpha,
        K,
        mu,
        dc,
        dp,
        dalpha,
        dK,
        dmu,
        on_l_c,
        on_l_p,
        on_l_alpha,
        on_l_K,
        on_l_mu,
        on_u_c,
        on_u_p,
        on_u_alpha,
        on_u_K,
        on_u_mu,
    ) = l.split()
    return dict(
        log=log,
        step=float(step),
        is_convex=parse_logical(is_convex),
        is_within=parse_logical(is_within),
        is_line_search=parse_logical(is_line_search),
        negative_log_likelihood=float(negative_log_likelihood),
        solution=[float(x) for x in [c, p, alpha, K, mu]],
        jacobian=[float(x) for x in [dc, dp, dalpha, dK, dmu]],
        on_lower=[parse_logical(x) for x in [on_l_c, on_l_p, on_l_alpha, on_l_K, on_l_mu]],
        on_upper=[parse_logical(x) for x in [on_u_c, on_u_p, on_u_alpha, on_u_K, on_u_mu]],
    )


def parse_logical(s):
    return s.lower() == 't'


def parse_version(fp):
    return int(fp.readline().split()[1])


def parse_argv(argv):
    if '--test' in argv:
        sys.argv = [arg for arg in argv if arg != '--test']
        unittest.main()
    elif len(argv) != 1:
        usage_and_exit()


def usage_and_exit():
    print("{} < /path/to/etas_solve_output".format(__file__), file=sys.stderr)
    exit(1)


class _Tester(unittest.TestCase):

    def test_parse_version(self):
        self.assertEqual(parse_version(io.StringIO('output_format_version: 6\n')), 6)


    def test_parse_etas_solve(self):
        input_str = """\
output_format_version: 6
 LOG:   1E-1      F F F   1 2 3 4 5 6 7 8 9 10 11     F T F F F F F F T F
 LOG:   1E1       T F F   12 13 14 15 16 17 18 19 20 21 22     F F F F F F F F F F
iterations
                   13
iter_best
                   13
best log-likelihood
   123.45
by_log: c, p, α, K, μ
  -1E0 -2E0 -3E0 -4E0 -5E0
by_log: Jacobian
  -6.0 -7.0 -8.0 -9.0 -10.0
by_log: Hessian
  1E0 2E0 3E0 4E0 5E0
  2E0 3E0 4E0 5E0 6E0
  3E0 4E0 5E0 6E0 7E0
  4E0 5E0 6E0 7E0 8E0
  5E0 6E0 7E0 8E0 9E0
c, p, α, K, μ, K_for_other_programs, μ_for_other_programs
   1 2 3 4 5 6 7
Jacobian
  10 20 30 40 50
Hessian
  1.0 2.0 3.0 4.0 5.0
  2.0 3.0 4.0 5.0 6.0
  3.0 4.0 5.0 6.0 7.0
  4.0 5.0 6.0 7.0 8.0
  5.0 6.0 7.0 8.0 9.0
converge_by_gradient, converge_by_step_size, converge_at_corner
 T F F
fixed
 F F F F F
on_lower
 F F F F F
on_upper
 F F F F F
"""
        input_fp = io.StringIO(input_str)
        parsed = parse_etas_solve(input_fp)
        expected = {
            'iter_best': 13,
            'fixed': [False, False, False, False, False],
            'converge_by_gradient': True,
            'version': 6,
            'solution': [1, 2, 3, 4, 5, 6, 7],
            'log_likelihood': 123.45,
            'iterations': 13,
            'on_upper': [False, False, False, False, False],
            'log': [
                {
                    'is_within': False,
                    'log': 'LOG:',
                    'jacobian': [7, 8, 9, 10, 11],
                    'solution': [2, 3, 4, 5, 6],
                    'negative_log_likelihood': 1,
                    'is_line_search': False,
                    'on_upper': [False, False, False, True, False],
                    'is_convex': False,
                    'step': 0.1,
                    'on_lower': [False, True, False, False, False]
                },
                {
                    'is_within': False,
                    'log': 'LOG:',
                    'jacobian': [18, 19, 20, 21, 22],
                    'solution': [13, 14, 15, 16, 17],
                    'negative_log_likelihood': 12,
                    'is_line_search': False,
                    'on_upper': [False, False, False, False, False],
                    'is_convex': True,
                    'step': 10.0,
                    'on_lower': [False, False, False, False, False]
                }
            ],
            'by_log': {
                'jacobian': [-6.0, -7.0, -8.0, -9.0, -10.0],
                'solution': [-1, -2, -3, -4, -5],
                'hessian': [
                    [1.0, 2.0, 3.0, 4.0, 5.0],
                    [2.0, 3.0, 4.0, 5.0, 6.0],
                    [3.0, 4.0, 5.0, 6.0, 7.0],
                    [4.0, 5.0, 6.0, 7.0, 8.0],
                    [5.0, 6.0, 7.0, 8.0, 9.0]
                ]
            },
            'on_lower': [False, False, False, False, False],
            'converge_by_step_size': False,
            'jacobian': [10, 20, 30, 40, 50],
            'converge_at_corner': False,
            'hessian': [
                [1.0, 2.0, 3.0, 4.0, 5.0],
                [2.0, 3.0, 4.0, 5.0, 6.0],
                [3.0, 4.0, 5.0, 6.0, 7.0],
                [4.0, 5.0, 6.0, 7.0, 8.0],
                [5.0, 6.0, 7.0, 8.0, 9.0]
            ]
        }
        self.assertAlmostEqual(parsed, expected)


if __name__ == '__main__':
    main(sys.argv)
