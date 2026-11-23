import { describe, expect, it } from 'vitest';
import { cn } from '../../src/lib/utils';

describe('cn', () => {
  it('joins class names and skips falsy values', () => {
    expect(cn('a', false, undefined, 'b')).toBe('a b');
  });

  it('lets the later Tailwind class win over a conflicting earlier one', () => {
    expect(cn('p-2', 'p-4')).toBe('p-4');
  });
});
